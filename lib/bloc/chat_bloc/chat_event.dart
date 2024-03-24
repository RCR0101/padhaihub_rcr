import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  types.TextMessage message;
  final String chatId;

  SendMessageEvent(this.message, this.chatId);
}

class LoadMessageEvent extends ChatEvent {
  final String chatId;

  LoadMessageEvent(this.chatId);
}
