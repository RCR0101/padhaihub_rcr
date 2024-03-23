import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  types.TextMessage message;

  SendMessageEvent(this.message);
}

class LoadMessageEvent extends ChatEvent {}
