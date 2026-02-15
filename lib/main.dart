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
        scaffoldBackgroundColor: const Color(0xFF050505),
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
    _startApp();
  }

  Future<void> _startApp() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print("System Log: Offline Mode active");
    }
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return _initialized ? const ChatScreen() : _loadingScreen();
  }

  Widget _loadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainCenterAxisAlignment.center,
          children: [
            Icon(Icons.shield_moon, size: 100, color: Colors.cyanAccent),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.cyanAccent),
            SizedBox(height: 20),
            Text("SECURE BOOT...", style: TextStyle(color: Colors.cyanAccent, letterSpacing: 3)),
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
  final String _myID = "User_A"; // معرف ثابت مؤقتاً للربط

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CardiaChat ✅", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () {})],
      ),
      body: Column(
        children: [
          Expanded(child: _messageStream()),
          _inputZone(),
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
            bool isMe = doc['senderId'] == _myID;
            String text = _enc.decrypt(doc['text'] ?? "");
            return _bubble(text, isMe);
          },
        );
      },
    );
  }

  Widget _bubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyanAccent.withOpacity(0.15) : Colors.white10,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
          ),
          border: Border.all(color: isMe ? Colors.cyanAccent.withOpacity(0.3) : Colors.white10),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _inputZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: "Enter command...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.cyanAccent,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
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
          ),
        ],
      ),
    );
  }
}
