import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nitdcodes007/components/button.dart';
import 'package:nitdcodes007/components/text_field.dart';
import 'dart:math';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String randomString = "";
  bool captchaVerified = false;

  final captchaTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    buildCaptcha();
  }

  void buildCaptcha() {
    const letters =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";

    const length = 6;
    final random = Random();

    randomString = String.fromCharCodes(List.generate(
        length, (index) => letters.codeUnitAt(random.nextInt(letters.length))));
    setState(() {});
  }

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(message)));
  }

  void signUp() async {
    bool registrationSuccessful = false;

    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    bool isValidEmail(String email) {
      // Check if the email contains exactly one '@'
      int atIndex = email.indexOf('@');
      if (atIndex == -1 || email.indexOf('@', atIndex + 1) != -1) {
        return false;
      }

      // Check if there is a '.' after the '@'
      int dotIndex = email.indexOf('.', atIndex);
      if (dotIndex == -1) {
        return false;
      }

      // Ensure there are characters before '@', between '@' and '.', and after '.'
      if (atIndex == 0 || dotIndex - atIndex < 2 || dotIndex == email.length - 1) {
        return false;
      }

      return true;
    }

    String email = emailTextController.text;

    if (!isValidEmail(email)) {
      Navigator.pop(context);
      displayMessage("Please enter a valid email address.");
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

    String password = passwordTextController.text;
    String confirmPassword = confirmPasswordTextController.text;

    if (password != confirmPassword) {
      Navigator.pop(context);
      displayMessage("Passwords don't match!");
      return;
    }

    if (!isValidPassword(password)) {
      Navigator.pop(context);
      displayMessage(
          "Password must be at least 8 characters, contain 1 special character, and 1 uppercase letter.");
      return;
    }

    setState(() {});

    if (!captchaVerified) {
      Navigator.pop(context);
      displayMessage("Captcha text does not match!");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
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
                  Icon(Icons.lock, size: 50),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          randomString,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () {
                            buildCaptcha();
                          },
                          icon: const Icon(Icons.refresh))
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        captchaVerified =
                            captchaTextController.text == randomString;
                      });
                    },
                    controller: captchaTextController,
                    obscureText: false,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      fillColor: Colors.grey[200],
                      filled: true,
                      hintText: "Enter captcha text here",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),

                  const SizedBox(height: 15),
                  MyButton(onTap: signUp, text: "Sign Up"),
                  const SizedBox(height: 15),
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
