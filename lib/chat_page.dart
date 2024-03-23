import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'bloc/chat_bloc/chat_bloc.dart';
import 'bloc/chat_bloc/chat_event.dart';
import 'bloc/chat_bloc/chat_state.dart';

var uuid = const Uuid();

class ChatPage extends StatefulWidget {
  final String userId;

  const ChatPage({Key? key, required this.userId}) : super(key: key);

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
    _chatBloc.add(LoadMessageEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
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
                messages: state.messages,
                onSendPressed: _handleSendPressed,
                user: _user,
              );
            }
            // Handle other states, such as initial or error
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

    _chatBloc.add(SendMessageEvent(textMessage));
  }
}
