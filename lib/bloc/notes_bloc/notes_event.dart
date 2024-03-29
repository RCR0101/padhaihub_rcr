import 'dart:io';

abstract class BroadcastEvent {}

class UploadPdfEvent extends BroadcastEvent {
  final File pdfFile;
  UploadPdfEvent(this.pdfFile);
}

class FetchPdfsEvent extends BroadcastEvent {}
