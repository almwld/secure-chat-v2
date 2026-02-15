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
        splashColor: Colors.cyanAccent.withOpacity(0.1),
        highlightColor: Colors.transparent,
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

class _BootSequenceState extends State<BootSequence> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
    _init();
  }

  Future<void> _init() async {
    try { await Firebase.initializeApp(); } catch (e) {}
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _ready ? const CardiaHome() : _buildSplash();
  }

  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: const Column(
            mainAxisAlignment: MainCenterAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, size: 80, color: Colors.cyanAccent),
              SizedBox(height: 20),
              CircularProgressIndicator(strokeWidth: 1, color: Colors.cyanAccent),
            ],
          ),
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
  bool _selfDestruct = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.unsplash.com/photo-1639762681485-074b7f938ba0?q=80&w=2064', fit: BoxFit.cover)),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: Container(color: Colors.black.withOpacity(0.8)))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _messageStream()),
                _buildAnimatedInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("CARDIA PRO", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.cyanAccent)),
          Switch.adaptive(
            value: _selfDestruct,
            activeColor: Colors.redAccent,
            onChanged: (v) => setState(() => _selfDestruct = v),
          ),
        ],
      ),
    );
  }

  Widget _messageStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return ListView.builder(
          reverse: true,
          physics: const BouncingScrollPhysics(), // تمرير مطاطي سلاسلي
          padding: const EdgeInsets.all(15),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            bool isMe = doc['senderId'] == _userName;
            String text = _enc.decrypt(doc['text'] ?? "");
            
            // إضافة أنيميشن لكل رسالة تظهر
            return TweenAnimationBuilder(
              duration: const Duration(milliseconds: 400),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOutBack,
              builder: (context, double val, child) {
                return Opacity(opacity: val, child: Transform.scale(scale: val, child: child));
              },
              child: _chatBubble(text, isMe, doc['isDestructible'] ?? false),
            );
          },
        );
      },
    );
  }

  Widget _chatBubble(String text, bool isMe, bool isDestruct) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe 
              ? [Colors.cyanAccent.withOpacity(0.2), Colors.cyanAccent.withOpacity(0.05)]
              : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
          ),
          border: Border.all(color: isDestruct ? Colors.redAccent.withOpacity(0.3) : Colors.white10),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildAnimatedInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(top: BorderSide(color: _selfDestruct ? Colors.redAccent.withOpacity(0.2) : Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: _selfDestruct ? "Self-destruct mode..." : "Type message...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white30),
              ),
            ),
          ),
          AnimatedRotation(
            turns: _selfDestruct ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              icon: Icon(Icons.bolt_rounded, color: _selfDestruct ? Colors.redAccent : Colors.cyanAccent, size: 30),
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
          ),
        ],
      ),
    );
  }
}
