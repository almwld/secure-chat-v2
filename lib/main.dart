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
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
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
  String? userImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('uid');
    if (id == null) {
      id = "User_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
      await prefs.setString('uid', id);
    }
    // رابط صورة افتراضي (يمكن تغييره لاحقاً)
    String img = prefs.getString('uimg') ?? "https://ui-avatars.com/api/?name=$id&background=random";
    setState(() {
      userId = id;
      userImage = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return CardiaHome(uid: userId!, uimg: userImage!);
  }
}

class CardiaHome extends StatefulWidget {
  final String uid;
  final String uimg;
  const CardiaHome({super.key, required this.uid, required this.uimg});
  @override
  State<CardiaHome> createState() => _CardiaHomeState();
}

class _CardiaHomeState extends State<CardiaHome> {
  final EncryptionService _enc = EncryptionService();
  final TextEditingController _con = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.uimg), radius: 18),
            const SizedBox(width: 10),
            Text("ID: ${widget.uid}", style: const TextStyle(fontSize: 14, color: Colors.cyanAccent)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
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
      stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, i) {
            var doc = snap.data!.docs[i];
            bool isMe = doc['senderId'] == widget.uid;
            String senderImg = doc['senderImg'] ?? "https://ui-avatars.com/api/?name=User";
            return _chatBubble(_enc.decrypt(doc['text']), isMe, senderImg);
          },
        );
      },
    );
  }

  Widget _chatBubble(String text, bool isMe, String img) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) CircleAvatar(backgroundImage: NetworkImage(img), radius: 15),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isMe ? Colors.cyanAccent.withOpacity(0.15) : Colors.white10,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          if (isMe) CircleAvatar(backgroundImage: NetworkImage(img), radius: 15),
        ],
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
                hintText: "Message...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.cyanAccent),
            onPressed: () {
              if (_con.text.isEmpty) return;
              FirebaseFirestore.instance.collection('messages').add({
                'text': _enc.encrypt(_con.text),
                'senderId': widget.uid,
                'senderImg': widget.uimg,
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
