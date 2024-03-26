import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:padhaihub_v2/pdf_view.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'bloc/chat_bloc/chat_bloc.dart';
import 'bloc/chat_bloc/chat_event.dart';
import 'bloc/chat_bloc/chat_state.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

var uuid = const Uuid();

class ChatPage extends StatefulWidget {
  final String userId;
  final String chatId;

  const ChatPage({Key? key, required this.userId, required this.chatId})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late types.User _user;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _user = types.User(id: widget.userId);
    _chatBloc = context.read<ChatBloc>();
    _chatBloc.add(LoadMessageEvent(widget.chatId));
  }

  Future<void> _handleAttachPressed() async {
    // Use FilePicker to let the user select a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = path.basename(file.path);

      try {
        // Upload to Firebase Storage
        String destination = 'chat_attachments/$fileName';
        await FirebaseStorage.instance.ref(destination).putFile(file);

        // After the upload is complete, you might want to send a message
        // in your chat that contains the download URL or a reference to the file
        String fileUrl =
            await FirebaseStorage.instance.ref(destination).getDownloadURL();
        final message = types.FileMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: uuid.v4(),
          name: result.files.single.name,
          size: result.files.single.size,
          uri: fileUrl,
        );
        _chatBloc.add(SendFileMessageEvent(message, widget.chatId, file));
      } catch (e) {
        Fluttertoast.showToast(msg: "$e", gravity: ToastGravity.CENTER);
      }
    } else {
      Fluttertoast.showToast(msg: "No File Selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Chat',
              style: GoogleFonts.abel(
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width *
                          0.08, // Adjusted size using screen width
                      fontWeight: FontWeight.w500,
                      letterSpacing: screenSize.width * 0.03))),
          backgroundColor: Colors.teal.shade300,
        ),
        body: BlocConsumer<ChatBloc, ChatStateBloc>(
          listener: (context, state) {
            if (state is ChatErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            if (state is ChatLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatMessagesUpdatedState) {
              return Chat(
                theme: DarkChatTheme(
                  inputBackgroundColor: Colors.teal.shade300,
                  backgroundColor: Colors.teal.shade300,
                ),
                messages: state.messages,
                // ignore: prefer_const_constructors
                scrollPhysics: BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.normal),
                onSendPressed: _handleSendPressed,
                onMessageTap: _handleMessageTap,
                user: _user,
                onAttachmentPressed: _handleAttachPressed,
              );
            }
            return const Center(
                child: Text("No messages or an error occurred"));
          },
        ));
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      id: uuid.v4(),
      text: message.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    _chatBloc.add(SendMessageEvent(textMessage, widget.chatId));
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
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
    final response = await Dio().download(url, filePath);
    return filePath; // Path of the downloaded file
  }
}
