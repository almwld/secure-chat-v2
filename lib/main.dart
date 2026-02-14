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
    debugPrint("Firebase connection error: $e");
  }
}

class CardiaUltimateApp extends StatelessWidget {
  const CardiaUltimateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080808),
        primaryColor: Colors.blueAccent,
      ),
      home: const MainControlPage(),
    );
  }
}

class MainControlPage extends StatefulWidget {
  const MainControlPage({super.key});
  @override
  State<MainControlPage> createState() => _MainControlPageState();
}

class _MainControlPageState extends State<MainControlPage> {
  int _selectedIndex = 0;
  final EncryptionService _encryption = EncryptionService();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية بتدرج نيون خافت
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D1B2A), Color(0xFF000000)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _selectedIndex == 0 ? _buildChatView() : _buildPlaceholder()),
                _buildGlassBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("CardiaChat PRO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: const Text("ONLINE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(15),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  bool isMe = doc['senderId'] == "Admin";
                  String msg = _encryption.decrypt(doc['text'] ?? "");
                  return _bubble(msg, isMe);
                },
              );
            },
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _bubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter secure message...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 70,
          color: Colors.white.withOpacity(0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.chat_bubble_outline, 0),
              _navItem(Icons.security_outlined, 1),
              _navItem(Icons.settings_outlined, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey, size: 28),
      onPressed: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(child: Text("Feature Locked - Encryption Active", style: TextStyle(color: Colors.grey)));
  }
}
