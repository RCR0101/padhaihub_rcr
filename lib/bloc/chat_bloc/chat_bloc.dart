import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class DatabaseRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> storeMessage(String chatId, types.TextMessage message) async {
    final createdAt = FieldValue.serverTimestamp(); // Get server timestamp

    // Add the message to the messages collection
    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'authorId': message.author.id,
      'text': message.text,
      'timestamp': createdAt,
    });

    // Update the createdAt field of the chat document
    await firestore.collection('chats').doc(chatId).set({
      'createdAt': createdAt,
    }, SetOptions(merge: true)); // Merge the createdAt field with existing data
  }

  Future<void> incrementUnreadMessages(String chatId, String userId) async {
    DocumentReference userUnreadRef = firestore
        .collection('chats')
        .doc(chatId)
        .collection('unreads')
        .doc(userId); // Reference to the user's unread document

    await firestore.runTransaction((transaction) async {
      DocumentSnapshot userUnreadSnapshot =
          await transaction.get(userUnreadRef);
      if (userUnreadSnapshot.exists &&
          userId != FirebaseAuth.instance.currentUser?.uid) {
        int currentUnread = userUnreadSnapshot['unreadCount'] ?? 0;
        transaction.update(userUnreadRef, {'unreadCount': currentUnread + 1});
      } else if (userId == FirebaseAuth.instance.currentUser?.uid) {
        transaction.set(userUnreadRef, {'unreadCount': 0});
      } else {
        transaction.set(userUnreadRef, {'unreadCount': 1});
      }
    });
  }

  Future<void> resetUnreadMessages(String chatId, String userId) async {
    DocumentReference userUnreadRef = firestore
        .collection('chats')
        .doc(chatId)
        .collection('unreads')
        .doc(FirebaseAuth.instance.currentUser
            ?.uid); // Reference to the user's unread document

    await firestore.runTransaction((transaction) async {
      DocumentSnapshot userUnreadSnapshot =
          await transaction.get(userUnreadRef);
      if (userUnreadSnapshot.exists) {
        transaction.update(userUnreadRef, {'unreadCount': 0});
      } else {
        transaction.set(userUnreadRef, {'unreadCount': 0});
      }
    });
  }

  Future<void> updateMessageWithNewPdf(
      String chatId, String messageId, String newPdfUrl, String newName) async {
    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'name': newName,
      'uri': newPdfUrl,
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
    String filePath = 'chat_attachments/$chatId/$fileName';

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

  Stream<List<types.Message>> getMessagesStream(String chatId) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final author = types.User(id: data['authorId']);

              // Check if the message is a text or file message
              if (data['type'] == 'pdf') {
                // Create a FileMessage for PDFs
                return types.FileMessage(
                  author: author,
                  createdAt: data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp).millisecondsSinceEpoch
                      : DateTime.now().millisecondsSinceEpoch,
                  id: doc.id,
                  mimeType: data['mimeType'],
                  name: data['name'],
                  size: data['size'],
                  uri: data['uri'],
                );
              } else {
                // Create a TextMessage for text
                return types.TextMessage(
                  author: author,
                  createdAt: data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp).millisecondsSinceEpoch
                      : DateTime.now().millisecondsSinceEpoch,
                  id: doc.id,
                  text: data['text'] ?? '',
                );
              }
            }).toList());
  }
}

class ChatBloc extends Bloc<ChatEvent, ChatStateBloc> {
  final DatabaseRepository databaseRepository;
  StreamSubscription<List<types.Message>>? _messagesSubscription;
  ChatBloc(this.databaseRepository) : super(ChatInitialState()) {
    on<LoadMessageEvent>(_onLoadMessageEvent);
    on<SendMessageEvent>(_onSendMessageEvent);
    on<SendFileMessageEvent>(_onSendFileMessageEvent);
    on<DeletePdfEvent>(_handleDeletePdfEvent);
    on<UploadNewPdfEvent>(_handleUploadNewPdf);
    on<UpdateMessageReferenceEvent>(_handleUpdateMessageReference);
    on<IncrementUnreadMessages>((event, emit) async {
      await databaseRepository.incrementUnreadMessages(
          event.chatId, event.userId);
    });
    on<ResetUnreadMessages>((event, emit) async {
      await databaseRepository.resetUnreadMessages(event.chatId, event.userId);
      // Optionally emit a state or handle errors
    });
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

  Future<void> _deleteMessage(String chatId, String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> _handleUploadNewPdf(
      UploadNewPdfEvent event, Emitter<ChatStateBloc> emit) async {
    // Ensure the file is a PDF by checking its extension
    final String fileName = path.basename(event.newPdfFile.path);
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      throw Exception("Only PDF files are supported.");
    }

    // Define the path in Firebase Storage specifically for PDFs
    String filePath = 'chat_attachments/${event.chatId}/$fileName';

    try {
      // Upload PDF file to Firebase Storage
      await FirebaseStorage.instance.ref(filePath).putFile(event.newPdfFile);

      // Get download URL
      final fileUrl =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      final updateEvent = UpdateMessageReferenceEvent(
          event.chatId, event.messageId, fileUrl, fileName);
      add(updateEvent);
    } catch (e) {
      throw Exception("Failed to store PDF file message: $e");
    }
  }

  Future<void> _handleUpdateMessageReference(
      UpdateMessageReferenceEvent event, Emitter<ChatStateBloc> emit) async {
    try {
      await databaseRepository.updateMessageWithNewPdf(
          event.chatId, event.messageId, event.newPdfUrl, event.newName);
      databaseRepository.getMessagesStream(event.chatId).listen(
        (updatedMessages) {
          emit(ChatMessagesUpdatedState(updatedMessages));
        },
        onError: (error) {
          emit(ChatErrorState(error.toString()));
        },
      );
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }

  Future<void> _onSendMessageEvent(
      SendMessageEvent event, Emitter<ChatStateBloc> emit) async {
    try {
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
      await databaseRepository.storeFileMessage(
          event.chatId, event.message, event.file);

      // Listen to the stream and emit updates.
      // Note: Ensure you manage the subscription to avoid memory leaks.
      databaseRepository.getMessagesStream(event.chatId).listen(
        (updatedMessages) {
          emit(ChatMessagesUpdatedState(updatedMessages));
        },
        onError: (error) {
          emit(ChatErrorState(error.toString()));
        },
      );
    } catch (error) {
      emit(ChatErrorState(error.toString()));
    }
  }

  Future<void> _handleDeletePdfEvent(
      DeletePdfEvent event, Emitter<ChatStateBloc> emit) async {
    try {
      //await FirebaseStorage.instance.ref(event.storagePath).delete(); fix this line, not deleting from storage, works fine otherwise
      await _deleteMessage(event.chatId, event.messageId);
      emit(DeletedPdfState());
    } catch (e) {
      Fluttertoast.showToast(msg: "$e");
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
