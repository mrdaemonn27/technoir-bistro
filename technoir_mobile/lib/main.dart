import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'splash_screen.dart'; // <-- Tambahkan import ini

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Technoir Bistro',
      theme: ThemeData.dark(),
      // Ganti halaman pertama yang dimuat menjadi SplashScreen
      home: const SplashScreen(), 
    );
  }
}