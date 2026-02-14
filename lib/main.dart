import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CardiaUltimateApp());
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("System: Waiting for Sync...");
  }
}

class CardiaUltimateApp extends StatelessWidget {
  const CardiaUltimateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ChatWallpaperScreen(),
    );
  }
}

class ChatWallpaperScreen extends StatefulWidget {
  const ChatWallpaperScreen({super.key});
  @override
  State<ChatWallpaperScreen> createState() => _ChatWallpaperScreenState();
}

class _ChatWallpaperScreenState extends State<ChatWallpaperScreen> {
  final EncryptionService _encryption = EncryptionService();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. طبقة الخلفية (صورة أو تدرج نيون)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF001219), Color(0xFF005F73), Color(0xFF001219)],
                ),
              ),
              // يمكنك لاحقاً إضافة صورة حقيقية هنا باستخدام Image.network
            ),
          ),
          
          // 2. المحتوى الرئيسي مع تأثير الزجاج
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: SafeArea(
              child: Column(
                children: [
                  _buildNeonHeader(),
                  Expanded(child: _buildMessagesArea()),
                  _buildModernInput(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.cyanAccent,
            child: Icon(Icons.shield, color: Colors.black),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CARDIA PRO", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.cyanAccent)),
              Text("ENCRYPTED NODE: 04-X", style: TextStyle(fontSize: 9, color: Colors.white54)),
            ],
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildMessagesArea() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            bool isMe = doc['senderId'] == "Admin";
            String msg = _encryption.decrypt(doc['text'] ?? "");
            return _chatBubble(msg, isMe);
          },
        );
      },
    );
  }

  Widget _chatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyanAccent.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isMe ? Colors.cyanAccent.withOpacity(0.5) : Colors.white10),
          boxShadow: isMe ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10)] : [],
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildModernInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.white.withOpacity(0.05),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Secure transmission...", border: InputBorder.none),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.small(
            backgroundColor: Colors.cyanAccent,
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
            child: const Icon(Icons.bolt, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
