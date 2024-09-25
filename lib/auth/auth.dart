import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nitdcodes007/auth/login_or_register.dart';
import 'package:nitdcodes007/pages/home_page.dart';
import 'package:nitdcodes007/pages/email_verification_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if(snapshot.data!.emailVerified == true){
              return const HomePage();
            }
            else{
              return EmailVerificationPage(user: snapshot.data!);
            }
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
