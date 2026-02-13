import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const SecureChatApp());
}

class SecureChatApp extends StatelessWidget {
  const SecureChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService _encryption = EncryptionService();
  bool isTyping = false;

  void _updateTypingStatus(bool typing) {
    _firestore.collection('status').doc('User_A').set({
      'isTyping': typing,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CardiaChat', style: TextStyle(fontSize: 18)),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('status').doc('User_B').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox();
                bool typing = snap.data!['isTyping'] ?? false;
                return Text(typing ? 'typing...' : 'online', 
                  style: TextStyle(fontSize: 12, color: typing ? Colors.greenAccent : Colors.blueGrey));
              },
            ),
          ],
        ),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        // إضافة خلفية أنيقة للدردشة
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://www.transparenttextures.com/patterns/dark-matter.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      bool isMe = docs[index]['senderId'] == 'User_A';
                      String msg = _encryption.decrypt(docs[index]['text']);
                      return _buildBubble(msg, isMe);
                    },
                  );
                },
              ),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe ? [Colors.blueAccent, Colors.blue] : [Colors.grey[800]!, Colors.grey[700]!],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.image, color: Colors.blueAccent), onPressed: () {}), // للصور لاحقاً
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (val) {
                if (!isTyping && val.isNotEmpty) {
                  isTyping = true;
                  _updateTypingStatus(true);
                } else if (isTyping && val.isEmpty) {
                  isTyping = false;
                  _updateTypingStatus(false);
                }
              },
              decoration: InputDecoration(
                hintText: 'Type securely...',
                fillColor: Colors.grey[900],
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _firestore.collection('messages').add({
                    'text': _encryption.encrypt(_controller.text),
                    'senderId': 'User_A',
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  _controller.clear();
                  _updateTypingStatus(false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
