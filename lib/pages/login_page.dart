import 'package:cloud_firestore/cloud_firestore.dart';
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

  bool isPasswordVisible = false;

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(message)));
  }

  Future<void> signIn() async {
    bool signInSuccessful = false;
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      String login = emailTextController.text.trim();
      String password = passwordTextController.text.trim();
      String email = login;

      // Check if the input is a username (no '@'), then get the corresponding email
      if (!login.contains('@')) {
        var userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('username', isEqualTo: login)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          email = userSnapshot.docs.first.id; // Get email from document ID
        } else {
          throw FirebaseAuthException(
              code: "user-not-found",
              message: "No user found with this username.");
        }
      }

      // Proceed with email/password login
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      signInSuccessful = true;

      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        displayMessage(e.message ?? "Login failed. Please try again.");
      }
    } finally {
      if (!signInSuccessful && context.mounted) {
        Navigator.pop(context);
        displayMessage("Error: Invalid credentials");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true, // Ensures bottom inset is respected
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
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
                      hintText: 'Email or Username',
                      obscureText: false),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: passwordTextController,
                    hintText: 'Password',
                    obscureText: !isPasswordVisible, // Password toggle
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
                    ),
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
                              fontWeight: FontWeight.bold, color: Colors.blue),
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
                          onTap: () => AuthService().signInWithGoogle(context),
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
