import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class DatabaseRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> storeMessage(String chatId, types.TextMessage message) async {
    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'authorId': message.author.id,
      'text': message.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> storeFileMessage(
      String chatId, types.FileMessage message, File file) async {
    // Ensure the file is a PDF by checking its extension
    final String fileName = file.path.split('/').last;
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      throw Exception("Only PDF files are supported.");
    }

    // Define the path in Firebase Storage specifically for PDFs
    String filePath = 'chat_attachments/$fileName';

    try {
      // Upload PDF file to Firebase Storage
      await FirebaseStorage.instance.ref(filePath).putFile(file);

      // Get download URL
      final fileUrl =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();

      // Store file message metadata in Firestore with 'pdf' type
      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'authorId': message.author.id,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'pdf', // Marking the message type as 'pdf'
        'filePath': filePath, // Storing the path for further reference
        'name': message.name,
        'size': message.size,
        'uri': fileUrl, // The URL to access the file
        'mimeType': 'application/pdf', // Setting MIME type as PDF
      });
    } catch (e) {
      throw Exception("Failed to store PDF file message: $e");
    }
  }

  Stream<List<types.TextMessage>> getMessagesStream(String chatId) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final author = types.User(id: data['authorId']);
              return types.TextMessage(
                author: author,
                createdAt: data['timestamp'] != null
                    ? (data['timestamp'] as Timestamp).millisecondsSinceEpoch
                    : DateTime.now().millisecondsSinceEpoch,
                id: doc.id,
                text: data['text'] ?? '',
              );
            }).toList());
  }
}

class ChatBloc extends Bloc<ChatEvent, ChatStateBloc> {
  final DatabaseRepository databaseRepository;

  ChatBloc(this.databaseRepository) : super(ChatInitialState()) {
    on<LoadMessageEvent>(_onLoadMessageEvent);
    on<SendMessageEvent>(_onSendMessageEvent);
    on<SendFileMessageEvent>(_onSendFileMessageEvent);
    _init();
  }

  void _init() {
    databaseRepository.firestore
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      snapshot.docs.map((doc) {
        final data = doc.data();
        final author = types.User(id: data['authorId']);
        return types.TextMessage(
          author: author,
          createdAt: (data['timestamp'] as Timestamp).millisecondsSinceEpoch,
          id: doc.id,
          text: data['text'] ?? '',
        );
      }).toList();
    });
  }

  // Example of handling a send message event with a chat ID
  Future<void> _onSendMessageEvent(
      SendMessageEvent event, Emitter<ChatStateBloc> emit) async {
    try {
      // Assuming chatId is determined and passed along with the event
      await databaseRepository.storeMessage(event.chatId, event.message);
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }

  Future<void> _onLoadMessageEvent(
      LoadMessageEvent event, Emitter<ChatStateBloc> emit) async {
    emit(ChatLoadingState());
    try {
      await for (final messages
          in databaseRepository.getMessagesStream(event.chatId)) {
        emit(ChatMessagesUpdatedState(messages));
      }
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }

  Future<void> _onSendFileMessageEvent(
      SendFileMessageEvent event, Emitter<ChatStateBloc> emit) async {
    try {
      // Ensure event.message is a FileMessage and event.file is the File to upload
      // ignore: unnecessary_type_check, unnecessary_null_comparison
      if (event.message is types.FileMessage && event.file != null) {
        await databaseRepository.storeFileMessage(
            event.chatId, event.message, event.file);
        // After successfully saving, you might fetch and emit updated messages
        // This assumes you have a method to fetch messages
        final updatedMessages =
            databaseRepository.getMessagesStream(event.chatId);
        emit(ChatMessagesUpdatedState(updatedMessages as List<types.Message>));
      } else {
        throw Exception(
            "Invalid message type or missing file for file message event");
      }
    } catch (error) {
      emit(ChatErrorState(error.toString()));
    }
  }
}
