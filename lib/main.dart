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
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
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
    try { await Firebase.initializeApp(); await Future.delayed(const Duration(seconds: 2)); } catch (e) {}
    if (mounted) setState(() => _ready = true);
  }
  @override
  Widget build(BuildContext context) {
    return _ready ? const CardiaHome() : _buildSplash();
  }
  Widget _buildSplash() {
    return const Scaffold(backgroundColor: Colors.black, body: Center(child: Icon(Icons.shield_rounded, size: 80, color: Colors.cyanAccent)));
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
  bool _selfDestruct = false; // خيار المستخدم

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.unsplash.com/photo-1639762681485-074b7f938ba0?q=80&w=2064', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.75))),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("CARDIA PRO", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.cyanAccent)),
          Row(
            children: [
              const Text("Destruct", style: TextStyle(fontSize: 10, color: Colors.white54)),
              Switch(
                value: _selfDestruct,
                activeColor: Colors.redAccent,
                onChanged: (val) => setState(() => _selfDestruct = val),
              ),
            ],
          ),
        ],
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
            return _chatBubble(text, isMe, doc['isDestructible'] ?? false);
          },
        );
      },
    );
  }

  Widget _chatBubble(String text, bool isMe, bool isDestruct) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyanAccent.withOpacity(0.15) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDestruct ? Colors.redAccent.withOpacity(0.5) : Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Colors.white)),
            if (isDestruct) const Icon(Icons.timer_outlined, size: 10, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: _selfDestruct ? "Sending destructible..." : "Secure message...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.send_rounded, color: _selfDestruct ? Colors.redAccent : Colors.cyanAccent),
            onPressed: () {
              if (_con.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('messages').add({
                  'text': _enc.encrypt(_con.text),
                  'senderId': _userName,
                  'isDestructible': _selfDestruct,
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
