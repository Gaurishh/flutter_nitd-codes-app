import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nitdcodes007/components/drawer.dart';
import 'package:nitdcodes007/components/text_field.dart';
import 'package:nitdcodes007/components/wall_post.dart';
import 'package:nitdcodes007/helper/helper_methods.dart';
import 'package:nitdcodes007/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User posts").add({
        'User Email': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    setState(() {
      textController.clear();
    });
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey[900],
        title: const Text(
          "NITD Codes </>",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Changed title color to white
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User posts")
                        .orderBy("TimeStamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final post = snapshot.data!.docs[index];
                              return WallPost(
                                  message: post['Message'],
                                  user: post['User Email'],
                                  postId: post.id,
                                  likes:
                                      List<String>.from(post['Likes'] ?? []),
                                  time: formatDate(post['TimeStamp']));
                            });
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: " + snapshot.error.toString()),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    })),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                      child: MyTextField(
                          controller: textController,
                          hintText: "Which problem has kept you thinking?",
                          obscureText: false)),
                  IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.arrow_circle_up)),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: MyDrawer(onProfileTap: goToProfilePage, onSignOut: signOut),
    );
  }
}
