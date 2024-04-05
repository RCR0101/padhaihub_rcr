// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padhaihub_v2/bloc/notes_bloc/notes_state.dart';
import 'package:padhaihub_v2/pdf_view.dart';
import 'package:path_provider/path_provider.dart';
import 'bloc/notes_bloc/notes_bloc.dart';
import 'dart:io';
import 'bloc/notes_bloc/notes_event.dart';

class MyNotesPage extends StatelessWidget {
  const MyNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BroadcastBLoC>().add(FetchPdfsEvent());
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.teal.shade300,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              context.read<BroadcastBLoC>().add(UserVisitedNotesPage());
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'BROADCAST',
            style: GoogleFonts.abel(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: screenSize.width * 0.08,
                fontWeight: FontWeight.w500,
                letterSpacing: screenSize.width * 0.03,
              ),
            ),
          ),
          backgroundColor: Colors.teal.shade300,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: screenSize.height * 0.01,
              ),
              Expanded(
                child: _buildPdfList(context),
              ),
              ElevatedButton(
                onPressed: () => _selectAndUploadPdf(context),
                child: Text('Upload PDF'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal.shade300,
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAndUploadPdf(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File pdfFile = File(result.files.single.path!);
      context.read<BroadcastBLoC>().add(UploadPdfEvent(pdfFile));
    } else {
      Fluttertoast.showToast(msg: "No File Selected");
    }
  }

  Widget _buildPdfList(BuildContext context) {
    return BlocConsumer<BroadcastBLoC, BroadcastState>(
      listener: (context, state) {
        if (state is BroadcastError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is BroadcastLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is BroadcastPdfListUpdated) {
          return ListView.builder(
            itemCount: state.pdfMessages.length,
            itemBuilder: (context, index) {
              final fileMessage = state.pdfMessages[index];
              return FutureBuilder<String>(
                future: getUserProfileImageUrl(fileMessage
                    .author.id), // Assuming this method is implemented
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return _buildListItem(context, fileMessage, snapshot.data!);
                  }
                  return CircularProgressIndicator(); // Show loading animation or default image while fetching
                },
              );
            },
          );
        } else {
          return Center(child: Text("No PDFs or Error Occurred"));
        }
      },
    );
  }

  Widget _buildListItem(
      BuildContext context, types.FileMessage fileMessage, String imageUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 20,
          ),
        ),
        Expanded(
          child: Card(
            color: Colors.cyan.shade300,
            elevation: 2.0,
            child: ListTile(
              title: Text(
                fileMessage.id,
                textAlign: TextAlign.center,
              ),
              onTap: () => _handleMessageTap(context, fileMessage),
            ),
          ),
        ),
      ],
    );
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    Fluttertoast.showToast(msg: "Loading...", gravity: ToastGravity.CENTER);
    try {
      if (message is types.FileMessage) {
        final filePath = await downloadPDF(message.uri, message.id);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PDFViewerPage(path: filePath),
        ));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "$e");
    }
  }

  Future<String> downloadPDF(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    // ignore: unused_local_variable
    final response = await Dio().download(url, filePath);
    return filePath; // Path of the downloaded file
  }

  Future<String> getUserProfileImageUrl(String uploaderId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uploaderId)
        .get();
    return docSnapshot.data()?['imageUrl'] ?? '';
  }
}
