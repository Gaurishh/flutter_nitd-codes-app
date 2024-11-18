import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nitdcodes007/components/comment.dart';
import 'package:nitdcodes007/components/comment_button.dart';
import 'package:nitdcodes007/components/delete_button.dart';
import 'package:nitdcodes007/components/like_button.dart';
import 'package:nitdcodes007/components/resolve_button.dart';
import 'package:nitdcodes007/components/user_email.dart';
import 'package:nitdcodes007/helper/helper_methods.dart';
import 'package:nitdcodes007/pages/chat_page.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final bool resolved;
  final List<String> likes;
  const WallPost(
      {super.key,
      required this.message,
      required this.resolved,
      required this.user,
      required this.postId,
      required this.likes,
      required this.time});

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  final _commentTextController = TextEditingController();

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

    print(widget.likes.length.toString());
  }

  void addComment(String commentText) {
    if (commentText.isEmpty) {
      // Show an error message using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment cannot be empty'),
          backgroundColor: Colors.red, // Red color for error
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // If the comment is not empty, add it to Firestore
    FirebaseFirestore.instance
        .collection("User posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now(),
    });
  }

  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add Comment"),
              content: TextField(
                controller: _commentTextController,
                decoration: InputDecoration(hintText: "Write a comment..."),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      addComment(_commentTextController.text);
                      Navigator.pop(context);
                      _commentTextController.clear();
                    },
                    child: Text("Save")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);

                      _commentTextController.clear();
                    },
                    child: Text("Cancel")),
              ],
            ));
  }

  void resolvePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Resolve Post"),
        content: (widget.resolved
            ? const Text(
                "Are you sure you want to re-open this post and mark it as unresolved?")
            : const Text("Are you sure you want to mark this post as solved?")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                // Update the 'resolved' field to true in Firestore
                await FirebaseFirestore.instance
                    .collection("User posts")
                    .doc(widget.postId)
                    .update({
                  'Resolved': (widget.resolved ? false : true)
                }).then((_) {
                  // Show a SnackBar indicating the post has been resolved
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: (widget.resolved
                          ? Text('Post re-opened successfully!')
                          : Text('Post resolved successfully!')),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Close the dialog
                  Navigator.pop(context);
                }).catchError((error) {
                  // Handle errors, if any
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to resolve post: $error'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                });
              },
              child: (widget.resolved ? Text("Re-open") :  Text("Resolve"))),
        ],
      ),
    );
  }

  void deletePost() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete post"),
              content: const Text("Are you sure you want to delete this post?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      final commentDocs = await FirebaseFirestore.instance
                          .collection("User posts")
                          .doc(widget.postId)
                          .collection("Comments")
                          .get();

                      for (var doc in commentDocs.docs) {
                        await FirebaseFirestore.instance
                            .collection("User posts")
                            .doc(widget.postId)
                            .collection("Comments")
                            .doc(doc.id)
                            .delete();
                      }

                      await FirebaseFirestore.instance
                          .collection("User posts")
                          .doc(widget.postId)
                          .delete()
                          .then((value) => print("post deleted"))
                          .catchError((error) =>
                              print("Failed to delete post: $error"));

                      Navigator.pop(context);
                    },
                    child: const Text("Delete")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userEmailComp(
                      resolved: widget.resolved,
                      text: widget.user,
                      onTap: () {
                        if (widget.user != currentUser.email) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(recieverEmail: widget.user),
                            ),
                          );
                        }
                      }),
                  const SizedBox(height: 10),
                  Text(
                    style: TextStyle(
                        decoration: widget.resolved
                            ? TextDecoration.lineThrough
                            : TextDecoration.none),
                    widget.message,
                    overflow: TextOverflow
                        .ellipsis, // Prevent overflow in case of long text
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      (widget.user == currentUser.email
                          ? ResolveButton(
                              onTap: resolvePost, resolved: widget.resolved)
                          : SizedBox.shrink()),
                      const SizedBox(width: 5),
                      (widget.user == currentUser.email
                          ? DeleteButton(onTap: deletePost)
                          : SizedBox.shrink())
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.time,
                      style: TextStyle(
                          decoration: widget.resolved
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: Colors.grey[500])),
                  const SizedBox(height: 10),
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  const SizedBox(height: 5),
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(
                      decoration: widget.resolved
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  CommentButton(onTap: showCommentDialog),
                  const SizedBox(height: 5),
                  // Update this part to dynamically display the comment count
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("User posts")
                        .doc(widget.postId)
                        .collection("Comments")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          '0',
                          style: TextStyle(
                            decoration: widget.resolved
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: Colors.grey,
                          ),
                        );
                      }

                      // Get the length of the comments
                      int commentCount = snapshot.data!.docs.length;
                      return Text(
                        '$commentCount',
                        style: TextStyle(
                          decoration: widget.resolved
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("User posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .orderBy("CommentTime", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    final commentData = doc.data() as Map<String, dynamic>;

                    return Comment(
                        resolved: widget.resolved,
                        text: commentData["CommentText"],
                        user: commentData["CommentedBy"],
                        time: formatDate(commentData["CommentTime"]));
                  }).toList(),
                );
              })
        ],
      ),
    );
  }
}
