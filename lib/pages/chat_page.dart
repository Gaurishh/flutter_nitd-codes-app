import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitdcodes007/auth/auth_service.dart';
import 'package:nitdcodes007/components/chat_bubble.dart';
import 'package:nitdcodes007/components/text_field.dart';
import 'package:nitdcodes007/services/chat/chat_service.dart';

class ChatPage extends StatelessWidget {
  final String recieverEmail;
  ChatPage({super.key, required this.recieverEmail});

  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(recieverEmail, _messageController.text);

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users') // Replace with your actual collection name
              .doc(
                  recieverEmail) // Use the receiver's email to fetch the document
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...'); // Show loading state
            }

            if (snapshot.hasError) {
              return const Text('Error'); // Handle errors
            }

            if (!snapshot.hasData ||
                snapshot.data == null ||
                !snapshot.data!.exists) {
              return Text(recieverEmail); // Handle missing document
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;

            return Text(
                userData?['username'] ?? 'Unknown'); // Safeguard username
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String? senderEmail = _authService.getCurrentUser()!.email;

    return StreamBuilder(
      stream: _chatService.getMessages(recieverEmail, senderEmail),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser =
        data['senderEmail'] == _authService.getCurrentUser()!.email;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(alignment: alignment, child: ChatBubble(message: data["message"], isCurrentUser: isCurrentUser));
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0, left: 15.0),
      child: Row(
        children: [
          Expanded(
              child: MyTextField(
                  controller: _messageController,
                  hintText: "Type a message...",
                  obscureText: false),),
          Container(
            decoration:
                const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            margin: const EdgeInsets.only(right: 15, left: 15),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.arrow_upward, color: Colors.white,),
            ),
          ),
        ],
      ),
    );
  }
}
