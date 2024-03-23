import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class ChatStateBloc {}

class ChatInitialState extends ChatStateBloc {}

class ChatLoadingState extends ChatStateBloc {}

class ChatMessagesUpdatedState extends ChatStateBloc {
  final List<types.Message> messages;

  ChatMessagesUpdatedState(this.messages);
}

class ChatMessagesLoadedState extends ChatStateBloc {
  final List<types.Message> messages;

  ChatMessagesLoadedState(this.messages);
}

class ChatErrorState extends ChatStateBloc {
  final String error;

  ChatErrorState(this.error);
}
