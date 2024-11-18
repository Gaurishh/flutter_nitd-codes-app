import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nitdcodes007/components/user_email.dart';
import 'package:nitdcodes007/pages/chat_page.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  final currentUser = FirebaseAuth.instance.currentUser!;

  Comment(
      {super.key, required this.text, required this.user, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              userEmailComp(
                      text: user,
                      onTap: () {
                        if (user != currentUser.email) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(recieverEmail: user),
                            ),
                          );
                        }
                      }),
              Text(time, style: TextStyle(color: Colors.grey[500])),
            ],
          )
        ],
      ),
    );
  }
}
