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
        scaffoldBackgroundColor: const Color(0xFF020202),
        primaryColor: Colors.cyanAccent,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainCenterAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              duration: const Duration(seconds: 2),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double val, child) => Opacity(opacity: val, child: child),
              child: const Icon(Icons.shield_rounded, size: 100, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 1),
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
      appBar: AppBar(
        title: const Text("CardiaChat", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.circle, color: Colors.greenAccent, size: 12), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _messageStream()),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _messageStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            bool isMe = doc['senderId'] == _userName;
            String text = _enc.decrypt(doc['text'] ?? "");
            return _chatBubble(text, isMe, doc['senderId'] ?? "User");
          },
        );
      },
    );
  }

  Widget _chatBubble(String text, bool isMe, String sender) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Text(sender, style: const TextStyle(fontSize: 8, color: Colors.white38)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isMe ? Colors.cyanAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
              ),
              border: Border.all(color: isMe ? Colors.cyanAccent.withOpacity(0.3) : Colors.white10),
            ),
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: "Transmit secure data...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.cyanAccent),
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
