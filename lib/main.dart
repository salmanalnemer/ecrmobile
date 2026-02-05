import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/auth/login_screen.dart'; // تأكد من المسار الصحيح


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase (ضرورية للإشعارات)
  await Firebase.initializeApp();

  // الاشتراك في إشعارات جميع المستخدمين
  await FirebaseMessaging.instance.subscribeToTopic('all_users');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ECR Mobile',

      // تعريف المسارات
      routes: {
        '/login': (context) => const LoginScreen(),
      },

      home: const LoginScreen(),
    );
  }
}
