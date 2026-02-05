import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart'; // تأكد من المسار الصحيح

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ECR Mobile',
      // هنا السر: تعريف المسارات
      routes: {
        '/login': (context) => const LoginScreen(), 
      },
      home: const LoginScreen(), // أو الصفحة الابتدائية لتطبيقك
    );
  }
}