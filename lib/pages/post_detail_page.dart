import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nitdcodes007/pages/chat_page.dart'; // Import intl package for date formatting

class PostDetailPage extends StatefulWidget {
  final String message;
  final String time;
  final String user;
  final List<String> likes;

  PostDetailPage({
    required this.message,
    required this.time,
    required this.user,
    required this.likes,
  });

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // Toggle like status
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        widget.likes.add(currentUser.email!); // Add current user to the likes list
      } else {
        widget.likes.remove(currentUser.email!); // Remove current user from the likes list
      }
    });
  }

  // Show the comment dialog
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Comment"),
          content: TextField(
            controller: _commentTextController,
            decoration: InputDecoration(hintText: "Enter your comment"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String comment = _commentTextController.text.trim();
                if (comment.isNotEmpty) {
                  // Add the comment to Firestore
                  FirebaseFirestore.instance.collection('comments').add({
                    'postId': widget.time,  // Use post's timestamp as an identifier
                    'comment': comment,
                    'user': currentUser.email,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text("Submit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse and format the date
    String inputDate = widget.time; // Input date in 'dd/MM/yyyy' format
    DateFormat inputFormat = DateFormat('dd/MM/yyyy');
    DateTime parsedDate = inputFormat.parse(inputDate); // Parse the string into DateTime
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(parsedDate); // Format the DateTime

    return Scaffold(
      appBar: AppBar(title: Text("Post Details")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display user email with a click listener (Assume userEmailComp is implemented elsewhere)
            GestureDetector(
              onTap: () {
                if (widget.user != currentUser.email) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(recieverEmail: widget.user),  // Assume ChatPage exists
                    ),
                  );
                }
              },
              child: Text(
                widget.user,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            // Display post message
            Text(widget.message),
            SizedBox(height: 10),
            // Display formatted time
            Text(formattedDate),
            SizedBox(height: 20),
            // Like button
            IconButton(
              icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt),
              onPressed: toggleLike,
            ),
            SizedBox(height: 20),
            // Comment button
            ElevatedButton(
              onPressed: showCommentDialog,
              child: Text("Add Comment"),
            ),
            SizedBox(height: 20),
            // Display comments using StreamBuilder
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('postId', isEqualTo: widget.time)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                var comments = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var commentData = comments[index];
                    return ListTile(
                      title: Text(commentData['comment']),
                      subtitle: Text(commentData['user']),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
