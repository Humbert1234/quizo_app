import 'package:flutter/material.dart';
import 'package:quizo_app/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Set LoginScreen as the initial screen
    );
  }
}
