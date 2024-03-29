import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class BroadcastState {}

class BroadcastInitial extends BroadcastState {}

class BroadcastLoading extends BroadcastState {}

class BroadcastPdfListUpdated extends BroadcastState {
  final List<types.FileMessage>
      pdfMessages; // Assuming FileMessage contains all necessary data
  BroadcastPdfListUpdated(this.pdfMessages);
}

class BroadcastError extends BroadcastState {
  final String message;
  BroadcastError(this.message);
}
