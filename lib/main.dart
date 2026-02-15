import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CardiaUltimateApp());
}

class CardiaUltimateApp extends StatelessWidget {
  const CardiaUltimateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020202),
      ),
      home: const RootHandler(),
    );
  }
}

class RootHandler extends StatefulWidget {
  const RootHandler({super.key});
  @override
  State<RootHandler> createState() => _RootHandlerState();
}

class _RootHandlerState extends State<RootHandler> {
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    _bootSystem();
  }

  Future<void> _bootSystem() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint("Core Sync Status: Local Cache Mode");
    }
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    // شاشة التحميل تظهر فقط أثناء الربط لتجنب البياض
    return _initialized ? const ChatScreen() : _splashScreen();
  }

  Widget _splashScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainCenterAxisAlignment.center,
          children: [
            const Icon(Icons.shield_rounded, size: 90, color: Colors.cyanAccent),
            const SizedBox(height: 25),
            const CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            Text("CARDIA SECURE BOOT", style: TextStyle(color: Colors.cyanAccent.withOpacity(0.6), letterSpacing: 4, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final EncryptionService _enc = EncryptionService();
  final TextEditingController _con = TextEditingController();
  final String _myID = "User_Admin"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CARDIA PRO", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.bolt, color: Colors.cyanAccent),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            bool isMe = doc['senderId'] == _myID;
            String text = _enc.decrypt(doc['text'] ?? "");
            return _messageBubble(text, isMe);
          },
        );
      },
    );
  }

  Widget _messageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyanAccent.withOpacity(0.12) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isMe ? Radius.zero : const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
          ),
          border: Border.all(color: isMe ? Colors.cyanAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  color: Colors.white.withOpacity(0.05),
                  child: TextField(
                    controller: _con,
                    decoration: const InputDecoration(hintText: "Enter Command...", border: InputBorder.none),
                  ),
                ),
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
                  'senderId': _myID,
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
