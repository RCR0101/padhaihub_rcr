import 'dart:io';

abstract class BroadcastEvent {}

class UploadPdfEvent extends BroadcastEvent {
  final File pdfFile;
  UploadPdfEvent(this.pdfFile);
}

class FetchPdfsEvent extends BroadcastEvent {}

class UserVisitedNotesPage extends BroadcastEvent {}

class CalculateUnreadNotesEvent extends BroadcastEvent {}
