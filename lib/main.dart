import 'package:flutter/material.dart';
import 'package:nitdcodes007/auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nitdcodes007/firebase_options.dart';
import 'package:nitdcodes007/theme/dark_theme.dart';
import 'package:nitdcodes007/theme/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const AuthPage(),
    );
  }
}
