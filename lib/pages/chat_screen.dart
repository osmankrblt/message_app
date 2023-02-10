import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Stack(
        children: [
          Column(
            children: [],
          )
        ],
      ),
    );
  }

  Future<bool> onBackPress() {
    Navigator.of(context).pop();

    return Future.value(true);
  }
}
