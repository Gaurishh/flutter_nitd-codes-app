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
  bool isPasswordVisible = false;
  String randomString = "";
  bool captchaVerified = false;
  bool passwordError = false; // Added for tracking password strength

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

  // Function to validate password as the user types
  void validatePassword(String password) {
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

    bool isValidPassword(String password) {
      if (password.length < 8) {
        return false;
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

    setState(() {
      passwordError = !isValidPassword(password); // Updates the error flag
    });
  }

  void signUp() async {
    bool registrationSuccessful = false;

    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    bool isValidEmail(String email) {
      int atIndex = email.indexOf('@');
      if (atIndex == -1 || email.indexOf('@', atIndex + 1) != -1) {
        return false;
      }

      int dotIndex = email.indexOf('.', atIndex);
      if (dotIndex == -1) {
        return false;
      }

      if (atIndex == 0 ||
          dotIndex - atIndex < 2 ||
          dotIndex == email.length - 1) {
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

    if(!email.endsWith("@nitdelhi.ac.in")){
      Navigator.pop(context);
      displayMessage("Only NITDians are allowed!");
      return;
    }

    String password = passwordTextController.text;
    String confirmPassword = confirmPasswordTextController.text;

    if (password != confirmPassword) {
      Navigator.pop(context);
      displayMessage("Passwords don't match!");
      return;
    }

    if (passwordError) {
      Navigator.pop(context);
      displayMessage(
          "Password must be at least 8 characters, contain 1 special character, and 1 uppercase letter.");
      return;
    }

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
        backgroundColor: Theme.of(context).colorScheme.background,
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

                  // Password field with visibility toggle and validation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextField(
                        controller: passwordTextController,
                        hintText: 'Password',
                        obscureText: !isPasswordVisible,
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
                        // Validate password as user types
                        onChanged: (value) {
                          validatePassword(value);
                        },
                      ),

                      // Red warning text for weak password
                      if (passwordError)
                        const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'Password must be at least 8 characters, contain 1 special character, and 1 uppercase letter.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),

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
                        padding: const EdgeInsets.only(
                            top: 5, bottom: 5, left: 20, right: 20),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          randomString,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
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
                      fillColor: Theme.of(context).colorScheme.secondary,
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
                          child: const Text(
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
