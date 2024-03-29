import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fluttertoast/fluttertoast.dart';
import 'notes_event.dart';
import 'notes_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class BroadcastBLoC extends Bloc<BroadcastEvent, BroadcastState> {
  BroadcastBLoC() : super(BroadcastInitial()) {
    on<UploadPdfEvent>(_onUploadPdfEvent);
    on<FetchPdfsEvent>(_onFetchPdfsEvent);
  }

  Future<void> _onUploadPdfEvent(
      UploadPdfEvent event, Emitter<BroadcastState> emit) async {
    emit(BroadcastLoading());
    try {
      // Upload the PDF and get its URL
      String pdfUrl = await uploadPdfAndGetUrl(event.pdfFile);
      String fileName = path.basenameWithoutExtension(event.pdfFile.path);

      // Reference to the document that will hold the metadata
      final docRef = FirebaseFirestore.instance
          .collection('pdfDocuments')
          .doc(fileName); // Document named after the file

      await docRef.set({
        'uri': pdfUrl, // The URL to access the PDF in Firebase Storage
        'uploadedAt':
            FieldValue.serverTimestamp(), // Firestore server timestamp
        // Add other metadata as needed, such as a title, description, etc.
        'id': fileName,
      });

      // Trigger fetching all PDFs including the newly uploaded one
      add(FetchPdfsEvent());
    } catch (e) {
      emit(BroadcastError(e.toString()));
    }
  }

  Future<void> _onFetchPdfsEvent(
      FetchPdfsEvent event, Emitter<BroadcastState> emit) async {
    emit(BroadcastLoading());
    try {
      List<types.FileMessage> pdfMessages =
          await fetchAllPdfMessages(); // Adjust this method accordingly
      emit(BroadcastPdfListUpdated(pdfMessages));
    } catch (e) {
      emit(BroadcastError(e.toString()));
    }
  }

  Future<String> uploadPdfAndGetUrl(File pdfFile) async {
    String fileName = path.basename(pdfFile.path);

    Reference ref =
        FirebaseStorage.instance.ref().child('public_attachments/$fileName');

    UploadTask uploadTask = ref.putFile(pdfFile);

    await uploadTask;

    String downloadUrl = await ref.getDownloadURL();

    return downloadUrl;
  }

  Future<List<types.FileMessage>> fetchAllPdfMessages() async {
    final collectionRef = FirebaseFirestore.instance.collection('pdfDocuments');
    List<types.FileMessage> pdfMessages = [];
    final querySnapshot = await collectionRef.get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      String? pdfUrl = data['uri'] as String?;
      // Assuming 'name' and 'createdAt' are fields in your document. Adjust as necessary.
      String? name = data['name'] as String?;
      // Create a FileMessage for each PDF. Provide default values or handle nulls as necessary.
      if (pdfUrl != null) {
        final fileMessage = types.FileMessage(
          author: types.User(
              id: 'user_id'), // Adjust as necessary. You might not need this for a public broadcast.
          createdAt:
              (data['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                  DateTime.now().millisecondsSinceEpoch,
          id: doc.id, // Using document ID as message ID
          mimeType: 'application/pdf',
          name: name ?? 'PDF Document',
          size: data['size'] as int? ??
              0, // Provide a default size or fetch from data
          uri: pdfUrl,
        );
        pdfMessages.add(fileMessage);
      }
    }

    return pdfMessages;
  }
}
