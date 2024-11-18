import 'package:flutter/material.dart';
import 'package:nitdcodes007/auth/auth_service.dart';
import 'package:nitdcodes007/components/user_tile.dart';
import 'package:nitdcodes007/pages/chat_page.dart';
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
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) =>
                  _buildUserListItem(userData, context)) // Map each user to a list item
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    // Skip the currently logged-in user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      // Use the username instead of the email
      final username = userData["username"] ?? "Unknown User"; // Fallback for missing usernames

      return UserTile(
        text: username, // Display the username
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(recieverEmail: userData["email"]),
            ),
          );
        },
      );
    } else {
      return Container(); // Return an empty container for the current user
    }
  }
}
