import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nitdcodes007/components/button.dart';
import 'package:nitdcodes007/components/text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailTextController = TextEditingController();

  @override
  void dispose(){
    emailTextController.dispose();
    super.dispose();
  }

  Future passwordReset() async{
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailTextController.text.trim());
      showDialog(context: context, builder: (context){
        return AlertDialog(content: Text("Password Reset Link Sent"));
      });
    } on FirebaseAuthException catch (e) {
      showDialog(context: context, builder: (context){
        return AlertDialog(content: Text(e.message.toString()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(elevation: 0,),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter your email to recieve the password reset link!"),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: MyTextField(
                        controller: emailTextController,
                        hintText: 'Email',
                        obscureText: false),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 100.0, right: 100.0),
              child: MyButton(onTap: passwordReset, text: "Reset Password"),
            )
          ],
        ));
  }
}
