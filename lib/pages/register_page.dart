// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nitdcodes007/components/button.dart';
import 'package:nitdcodes007/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(message)));
  }

  void signUp() async {
    bool registrationSuccessful = false;

    // Show loading indicator
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    // Password validation
    String password = passwordTextController.text;
    String confirmPassword = confirmPasswordTextController.text;

    if (password != confirmPassword) {
      Navigator.pop(context);
      displayMessage("Passwords don't match!");
      return;
    }

    List<String> specialCharacters = [
      '!',
      '@',
      '#',
      '\$',
      '%',
      '^',
      '&',
      '*',
      '(',
      ')',
      '-',
      '_',
      '=',
      '+',
      '[',
      ']',
      '{',
      '}',
      ';',
      ':',
      '\'',
      '"',
      ',',
      '.',
      '<',
      '>',
      '/',
      '?',
      '|',
      '`',
      '~'
    ];

    // Validation function to check conditions manually
    bool isValidPassword(String password) {
      if (password.length < 8) {
        return false; // Password length should be at least 8 characters
      }

      bool hasUppercase = false;
      bool hasSpecialCharacter = false;

      for (int i = 0; i < password.length; i++) {
        String char = password[i];

        if (char.toUpperCase() == char && char.toLowerCase() != char) {
          hasUppercase = true;
        }

        if (specialCharacters.contains(char)) {
          hasSpecialCharacter = true;
        }

        if (hasUppercase && hasSpecialCharacter) {
          break;
        }
      }

      return hasUppercase && hasSpecialCharacter;
    }

    if (!isValidPassword(password)) {
      Navigator.pop(context);
      displayMessage(
          "Password must be at least 8 characters, contain 1 special character, and 1 uppercase letter.");
      return;
    }

    try {
      UserCredential userCredential = await (
              email: emailTextController.text, password: password);

      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split('@')[0],
        'bio': "Empty bio...",
      });

      registrationSuccessful = true;

      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        displayMessage(e.code);
      }
    } finally {
      if (!registrationSuccessful && context.mounted) {
        Navigator.pop(context);
        displayMessage("Error processing the request");
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
                  Text("Create an account!"),
                  const SizedBox(height: 25),
                  MyTextField(
                      controller: emailTextController,
                      hintText: 'Email',
                      obscureText: false),
                  const SizedBox(height: 15),
                  MyTextField(
                      controller: passwordTextController,
                      hintText: 'Password',
                      obscureText: true),
                  const SizedBox(height: 15),
                  MyTextField(
                      controller: confirmPasswordTextController,
                      hintText: 'Confirm Password',
                      obscureText: true),
                  const SizedBox(height: 15),
                  MyButton(onTap: signUp, text: "Sign Up"),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?",
                          style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 4),
                      GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Login here",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
