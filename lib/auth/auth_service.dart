import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:github_signin_promax/github_signin_promax.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

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

  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser == null) {
      return;
    }

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    return await _auth.signInWithCredential(credential);
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
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
