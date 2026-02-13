import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'security.dart'; // ملف التشفير الخاص بنا

void main() async {
  // التأكد من تهيئة روابط Flutter قبل أي شيء
  WidgetsFlutterBinding.ensureInitialized();
  
  // تشغيل Firebase باستخدام ملف google-services.json الذي رفعناه
  await Firebase.initializeApp();
  
  runApp(const SecureChatApp());
}

class SecureChatApp extends StatelessWidget {
  const SecureChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardiaChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CardiaChat Secure')),
      body: const Center(
        child: Text('Firebase Connected & Encryption Ready!'),
      ),
    );
  }
}
