import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nitdcodes007/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text("Edit " + field,
                  style: const TextStyle(color: Colors.white)),
              content: TextField(
                autofocus: true,
                cursorColor: Theme.of(context).colorScheme.tertiary,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Enter new $field",
                    hintStyle: const TextStyle(color: Colors.grey)),
                onChanged: (value) {
                  newValue = value;
                },
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.of(context).pop(newValue),
                )
              ],
            ));

    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "User Profile",
            style: TextStyle(
              color: Colors.white, // Changed title color to white
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: usersCollection.doc(currentUser.email).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.hasData) {
                // Get user data or default to empty map
                final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};

                // Fallback to default values if fields are missing
                final username = userData['username'] ?? currentUser.email!.split('@')[0];
                final bio = userData['bio'] ?? 'Empty bio...';

                return ListView(
                  children: [
                    const SizedBox(height: 50),
                    const Icon(Icons.person, size: 72),
                    Text(
                      currentUser.email!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text("My Details",
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                    MyTextBox(
                      text: username,
                      sectionName: 'Username',
                      onPressed: () => editField('username'),
                    ),
                    MyTextBox(
                      text: bio,
                      sectionName: 'Bio',
                      onPressed: () => editField('bio'),
                    ),
                  ],
                );
              }

              return const Center(
                child: Text('No user data found.'),
              );
            }));
  }
}
