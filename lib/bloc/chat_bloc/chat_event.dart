import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  types.TextMessage message;
  final String chatId;
  final String recipientId;
  SendMessageEvent(this.message, this.chatId, this.recipientId);
}

class LoadMessageEvent extends ChatEvent {
  final String chatId;

  LoadMessageEvent(this.chatId);
}

class SendFileMessageEvent extends ChatEvent {
  types.FileMessage message;
  final String chatId;
  final File file;
  final String recipientId;
  SendFileMessageEvent(this.message, this.chatId, this.file, this.recipientId);
}

class DeletePdfEvent extends ChatEvent {
  final String chatId;
  final String messageId;
  final String storagePath;

  DeletePdfEvent(
      {required this.chatId,
      required this.messageId,
      required this.storagePath});
}

class UploadNewPdfEvent extends ChatEvent {
  final String chatId;
  final String messageId;
  final File newPdfFile;

  UploadNewPdfEvent(this.chatId, this.messageId, this.newPdfFile);
}

class UpdateMessageReferenceEvent extends ChatEvent {
  final String chatId;
  final String messageId;
  final String newPdfUrl;
  final String newName;
  UpdateMessageReferenceEvent(
      this.chatId, this.messageId, this.newPdfUrl, this.newName);
}

class IncrementUnreadMessages extends ChatEvent {
  final String chatId;
  final String userId;

  IncrementUnreadMessages(this.chatId, this.userId);
}

class ResetUnreadMessages extends ChatEvent {
  final String chatId;
  final String userId;

  ResetUnreadMessages(this.chatId, this.userId);
}
