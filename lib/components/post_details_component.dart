import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nitdcodes007/components/comment.dart';
import 'package:nitdcodes007/components/comment_button.dart';
import 'package:nitdcodes007/components/like_button.dart';
import 'package:nitdcodes007/helper/helper_methods.dart';

class PostDetailsComponent extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final bool resolved;
  final List<String> likes;

  const PostDetailsComponent({
    super.key,
    required this.message,
    required this.user,
    required this.time,
    required this.postId,
    required this.resolved,
    required this.likes,
  });

  @override
  State<PostDetailsComponent> createState() => _PostDetailsComponentState();
}

class _PostDetailsComponentState extends State<PostDetailsComponent> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  void addComment() {
    final commentText = _commentController.text;

    if (commentText.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("User posts")
          .doc(widget.postId)
          .collection("Comments")
          .add({
        "CommentText": commentText,
        "CommentedBy": currentUser.email,
        "CommentTime": Timestamp.now(),
      });

      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post details
            Text(
              widget.user,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.time,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                LikeButton(
                  isLiked: isLiked,
                  onTap: toggleLike,
                ),
                const SizedBox(width: 16),
                CommentButton(onTap: () {}),
              ],
            ),
            const Divider(thickness: 1, height: 32),
            // Comment section
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .orderBy("CommentTime", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final comment = snapshot.data!.docs[index];
                        return Comment(
                          text: comment['CommentText'],
                          user: comment['CommentedBy'],
                          time: formatDate(comment['CommentTime']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            // Add comment field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
