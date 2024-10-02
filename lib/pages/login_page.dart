// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nitdcodes007/auth/auth_service.dart';
import 'package:nitdcodes007/components/button.dart';
import 'package:nitdcodes007/components/square_tile.dart';
import 'package:nitdcodes007/components/text_field.dart';
import 'package:nitdcodes007/pages/forgot_pw_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  bool isPasswordVisible = false; // Add this line

  void displayMessage(String message){
    showDialog(context: context, builder: (context) => AlertDialog(title: Text(message)));
  }

  void signIn() async {
    bool signInSuccessful = false;
    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text);

      signInSuccessful = true;

      if(context.mounted){
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if(context.mounted){
        Navigator.pop(context);
        displayMessage(e.code);
      }
    } finally {
      if(!signInSuccessful && context.mounted){
        Navigator.pop(context);
        displayMessage("Error: Invalid credentials");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 75),
                  const SizedBox(height: 25),
                  Text("Welcome back!"),
                  const SizedBox(height: 25),
                  MyTextField(
                      controller: emailTextController,
                      hintText: 'Email',
                      obscureText: false),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: passwordTextController,
                    hintText: 'Password',
                    obscureText: !isPasswordVisible, // Bind this to the toggle state
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ), // Add eye icon here
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ForgotPasswordPage();
                          }));
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MyButton(onTap: signIn, text: "Sign In"),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Not a member?",
                          style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 4),
                      GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Register here",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ))
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(
                          onTap: () => AuthService().signInWithGoogle(),
                          imagePath: 'images/google_icon.png'),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
