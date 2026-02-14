import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'security.dart'; // تأكد أن هذا الملف موجود

void main() {
  // 1. أهم خطوة: تشغيل المحرك فوراً
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. تشغيل التطبيق فوراً دون انتظار أي شيء
  runApp(const CardiaSafeApp());
}

class CardiaSafeApp extends StatefulWidget {
  const CardiaSafeApp({super.key});

  @override
  State<CardiaSafeApp> createState() => _CardiaSafeAppState();
}

class _CardiaSafeAppState extends State<CardiaSafeApp> {
  // متغير لتتبع حالة النظام
  bool _isFirebaseReady = false;
  String _statusMessage = "Initializing Core Systems...";

  @override
  void initState() {
    super.initState();
    _initializeSystem();
  }

  // دالة التهيئة الآمنة (لن توقف الشاشة)
  Future<void> _initializeSystem() async {
    try {
      await Firebase.initializeApp();
      // تأخير بسيط جمالي لرؤية الشعار
      await Future.delayed(const Duration(seconds: 2)); 
      setState(() {
        _isFirebaseReady = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Connection Mode: Offline/Cached";
        _isFirebaseReady = true; // السماح بالدخول حتى لو فشل الاتصال
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050505),
        primaryColor: Colors.cyanAccent,
      ),
      home: _isFirebaseReady 
          ? const MainChatScreen() // إذا جاهز، اعرض الشات
          : _buildLoadingScreen(), // إذا لا، اعرض شاشة تحميل احترافية
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.cyanAccent),
            const SizedBox(height: 20),
            Text(_statusMessage, style: const TextStyle(color: Colors.white54, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

// --- شاشة الدردشة الرئيسية ---
class MainChatScreen extends StatefulWidget {
  const MainChatScreen({super.key});
  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  final EncryptionService _encryption = EncryptionService();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية متدرجة ثابتة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F172A), Color(0xFF000000)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildMessagesList()),
                _buildInputZone(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.cyanAccent.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("CardiaChat", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: const Text("SECURE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Connection Error", style: TextStyle(color: Colors.red)));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            return _messageBubble(doc);
          },
        );
      },
    );
  }

  Widget _messageBubble(QueryDocumentSnapshot doc) {
    bool isMe = doc['senderId'] == "Admin";
    String decrypted = _encryption.decrypt(doc['text'] ?? "");
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyanAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isMe ? Colors.cyanAccent.withOpacity(0.5) : Colors.transparent),
        ),
        child: Text(decrypted, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInputZone() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black54,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type encrypted message...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.cyanAccent),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('messages').add({
                  'text': _encryption.encrypt(_controller.text),
                  'senderId': "Admin",
                  'createdAt': FieldValue.serverTimestamp(),
                });
                _controller.clear();
              }
            },
          )
        ],
      ),
    );
  }
}
