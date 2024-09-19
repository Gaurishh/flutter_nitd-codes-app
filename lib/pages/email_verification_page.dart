import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nitdcodes007/auth/auth.dart';
import 'package:nitdcodes007/auth/auth_service.dart';
import 'package:nitdcodes007/components/button.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _auth = AuthService();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _auth.sendEmailVerificationLink();
    timer = Timer.periodic(Duration(seconds: 5), (timer){
      FirebaseAuth.instance.currentUser?.reload();
      if(FirebaseAuth.instance.currentUser!.emailVerified){
        timer.cancel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
            alignment: Alignment.center,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Email sent for verification!", textAlign: TextAlign.center,),
                    const SizedBox(height: 20),
                    MyButton(onTap: () async{_auth.sendEmailVerificationLink();}, text: "Resend E-mail")
                  ],
                ))));
  }
}
