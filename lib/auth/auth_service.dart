import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  // signInWithGithub({required BuildContext context}){
  //   // create required params
  //   var params = GithubSignInParams(
  //     clientId: 'Ov23li7hZrFICd35aBaW',
  //     clientSecret: 'c68c5fcecd0fe317be0a841bb5f3e11bd3801d4d',
  //     redirectUrl: 'https://nitdcodes007.firebaseapp.com/__/auth/handler',
  //     scopes: 'read:user,user:email',
  //   );

  //   // Push [GithubSigninScreen] to perform login then get the [GithubSignInResponse]
  //   Navigator.of(context).push(MaterialPageRoute(builder: (builder) {
  //     return GithubSigninScreen(
  //       params: params,
  //       headerColor: const Color.fromARGB(192, 0, 0, 0),
  //       title: 'Login with GitHub',
  //     );
  //   })).then((value) async{
  //     final githubSignInResponse = value as GithubSignInResponse;

  //     final githubAuthCredential = GithubAuthProvider.credential('${githubSignInResponse.accessToken}');

  //     await _auth.signInWithCredential(githubAuthCredential);

  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful")));
  //   });
  //   // GithubAuthProvider githubAuthProvider = GithubAuthProvider();
  //   // return await _auth.signInWithProvider(githubAuthProvider);
  // }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the Google Sign-In process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // If the user cancels the sign-in process
      if (gUser == null) {
        print("User canceled the sign-in process.");
        return;
      }

      // Fetch the user's email
      final String email = gUser.email;

      // Check if the email ends with "@nitdelhi.ac.in"
      if (!email.endsWith("@nitdelhi.ac.in")) {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Only NIT Delhi emails are allowed."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        // Sign out the user from GoogleSignIn if necessary
        await GoogleSignIn().signOut();
        return;
      }

      // Get Google authentication details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a credential for Firebase authentication
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Reference to the user document in Firestore
      final userDoc = FirebaseFirestore.instance.collection("Users").doc(email);

      // Fetch the document to check existing fields
      final DocumentSnapshot docSnapshot = await userDoc.get();

      // Extract existing values if the document exists
      String username = email.split('@')[0];
      String bio = "Empty bio..."; // Default bio

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        username =
            data['username'] ?? username; // Keep existing username if present
        bio = data['bio'] ?? bio; // Keep existing bio if present
      }

      // Update the document without overwriting existing fields
      await userDoc.set(
          {
            'username': username,
            'bio': bio,
          },
          SetOptions(
              merge: true)); // Merge ensures only specified fields are updated

      print("Sign-in successful and Firestore updated. Email: $email");
    } catch (e) {
      print("Error during Google sign-in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred during sign-in."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
    }
  }
}
