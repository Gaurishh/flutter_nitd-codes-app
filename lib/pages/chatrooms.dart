import 'package:flutter/material.dart';
import 'package:nitdcodes007/auth/auth_service.dart';
import 'package:nitdcodes007/services/chat/chat_service.dart';

class ChatRooms extends StatelessWidget {
  ChatRooms({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Chats",
            style: TextStyle(
              color: Colors.white, // Changed title color to white
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
        ),
    );
  }
}
