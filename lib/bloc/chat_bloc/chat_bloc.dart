import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class DatabaseRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> storeMessage(types.TextMessage message) async {
    await firestore.collection('messages').add({
      'authorId': message.author.id,
      'text': message.text,
      'timestamp': FieldValue.serverTimestamp(), // Use server timestamp
    });
  }

  Stream<List<types.TextMessage>> getMessagesStream() {
    return firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final author = types.User(id: data['authorId']);
              return types.TextMessage(
                author: author,
                // Use a null check or provide a fallback value for createdAt because
                // the document might not have a timestamp yet if it's being processed.
                createdAt:
                    (data['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ??
                        DateTime.now().millisecondsSinceEpoch,
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
          text: data['text'],
        );
      }).toList();
    });
  }

  Future<void> _onSendMessageEvent(
      SendMessageEvent event, Emitter<ChatStateBloc> emit) async {
    emit(ChatLoadingState());
    try {
      await databaseRepository.storeMessage(event.message);
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }

  Future<void> _onLoadMessageEvent(
      LoadMessageEvent event, Emitter<ChatStateBloc> emit) async {
    emit(ChatLoadingState());
    try {
      await for (final messages in databaseRepository.getMessagesStream()) {
        emit(ChatMessagesUpdatedState(messages));
      }
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }
}
