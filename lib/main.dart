import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CardiaChatApp());
}

class CardiaChatApp extends StatelessWidget {
  const CardiaChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardiaChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const BootSequence(),
    );
  }
}

class BootSequence extends StatefulWidget {
  const BootSequence({super.key});
  @override
  State<BootSequence> createState() => _BootSequenceState();
}

class _BootSequenceState extends State<BootSequence> {
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await Firebase.initializeApp();
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {}
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return _ready ? const CardiaHome() : _buildSplash();
  }

  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainCenterAxisAlignment.center,
          children: [
            const Icon(Icons.shield_rounded, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            const Text("CARDIA SYSTEM", style: TextStyle(letterSpacing: 5, color: Colors.cyanAccent, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class CardiaHome extends StatefulWidget {
  const CardiaHome({super.key});
  @override
  State<CardiaHome> createState() => _CardiaHomeState();
}

class _CardiaHomeState extends State<CardiaHome> {
  final EncryptionService _enc = EncryptionService();
  final TextEditingController _con = TextEditingController();
  final String _userName = "Admin_Cardia";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. طبقة الخلفية الفنية (Background Image Layer)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?q=80&w=2064&auto=format&fit=crop', // صورة تقنية فنية
              fit: BoxFit.cover,
            ),
          ),
          // 2. طبقة التعتيم لجعل الرسائل واضحة
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),
          // 3. محتوى التطبيق
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _messageStream()),
                _inputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          color: Colors.white.withOpacity(0.05),
          child: Row(
            mainAxisAlignment: MainCenterAxisAlignment.spaceBetween,
            children: [
              const Text("CARDIA PRO", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.cyanAccent)),
              const Icon(Icons.circle, color: Colors.greenAccent, size: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(15),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            bool isMe = doc['senderId'] == _userName;
            String text = _enc.decrypt(doc['text'] ?? "");
            return _chatBubble(text, isMe);
          },
        );
      },
    );
  }

  Widget _chatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.cyanAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isMe ? Colors.cyanAccent.withOpacity(0.3) : Colors.white10),
            ),
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black.withOpacity(0.8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: "Secure Link...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.bolt_rounded, color: Colors.cyanAccent),
            onPressed: () {
              if (_con.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('messages').add({
                  'text': _enc.encrypt(_con.text),
                  'senderId': _userName,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                _con.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
