import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';

void main() {
  // 1. ضمان تشغيل محرك فلوتر أولاً
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. تشغيل الواجهة فوراً دون انتظار أي شيء
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SimpleChat(),
  ));
}

class SimpleChat extends StatefulWidget {
  const SimpleChat({super.key});
  @override
  State<SimpleChat> createState() => _SimpleChatState();
}

class _SimpleChatState extends State<SimpleChat> {
  bool _isInitialized = false;
  final EncryptionService _enc = EncryptionService();

  @override
  void initState() {
    super.initState();
    // بدء تهيئة فيربيس في الخلفية
    _initFirebase();
  }

  void _initFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint("Firebase Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CardiaChat ✅"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Center(
        child: _isInitialized 
          ? const Text("Connected & Secure", style: TextStyle(color: Colors.green))
          : const CircularProgressIndicator(),
      ),
    );
  }
}
