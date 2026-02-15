import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CardiaChatApp());
}

class CardiaChatApp extends StatelessWidget {
  const CardiaChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardiaChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        fontFamily: 'Roboto',
      ),
      home: const UserHandler(),
    );
  }
}

class UserHandler extends StatefulWidget {
  const UserHandler({super.key});
  @override
  State<UserHandler> createState() => _UserHandlerState();
}

class _UserHandlerState extends State<UserHandler> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  // توليد معرف فريد للمستخدم الحقيقي
  _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('uid');
    if (id == null) {
      id = "User_${DateTime.now().millisecondsSinceEpoch}";
      await prefs.setString('uid', id);
    }
    setState(() => userId = id);
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return CardiaHome(uid: userId!);
  }
}

class CardiaHome extends StatefulWidget {
  final String uid;
  const CardiaHome({super.key, required this.uid});
  @override
  State<CardiaHome> createState() => _CardiaHomeState();
}

class _CardiaHomeState extends State<CardiaHome> {
  final EncryptionService _enc = EncryptionService();
  final TextEditingController _con = TextEditingController();
  bool _isDestruct = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CARDIA PRO", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const Icon(Icons.bolt, color: Colors.cyanAccent),
        actions: [
          Switch(
            value: _isDestruct,
            activeColor: Colors.redAccent,
            onChanged: (v) => setState(() => _isDestruct = v),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _messageList()),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _messageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).limit(50).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, i) {
            var doc = snap.data!.docs[i];
            bool isMe = doc['senderId'] == widget.uid;
            return _chatBubble(_enc.decrypt(doc['text']), isMe, doc['isDestruct'] ?? false);
          },
        );
      },
    );
  }

  Widget _chatBubble(String text, bool isMe, bool isDest) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyanAccent.withOpacity(0.1) : Colors.white10,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDest ? Colors.redAccent : Colors.transparent),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: _isDestruct ? "Safe Destruct Active..." : "Write message...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: _isDestruct ? Colors.redAccent : Colors.cyanAccent),
            onPressed: () {
              if (_con.text.isEmpty) return;
              FirebaseFirestore.instance.collection('messages').add({
                'text': _enc.encrypt(_con.text),
                'senderId': widget.uid,
                'isDest': _isDestruct,
                'createdAt': FieldValue.serverTimestamp(),
              });
              _con.clear();
            },
          )
        ],
      ),
    );
  }
}
