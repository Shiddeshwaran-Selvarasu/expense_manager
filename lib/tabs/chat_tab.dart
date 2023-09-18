import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your Chats will Appear here'),
      //TODO: Chats tab
    );
  }
}
