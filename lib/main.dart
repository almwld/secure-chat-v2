import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'security.dart';

void main() async {
  // تفعيل الربط مع واجهات أندرويد
  WidgetsFlutterBinding.ensureInitialized();
  
  // تشغيل الواجهة فوراً وعدم انتظار Firebase (لتجنب الشاشة السوداء)
  Firebase.initializeApp().then((_) {
    debugPrint("Firebase Connected Successfully");
  }).catchError((e) => debugPrint("Offline Mode Active: $e"));

  runApp(const SecureChatApp());
}

class SecureChatApp extends StatelessWidget {
  const SecureChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CardiaChat',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
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
  final String currentUserId = "User_A";

  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      String encryptedText = _encryption.encrypt(_controller.text);
      // الحفظ في Firestore (يدعم التخزين المحلي تلقائياً)
      _firestore.collection('messages').add({
        'text': encryptedText,
        'createdAt': FieldValue.serverTimestamp(),
        'senderId': currentUserId,
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 CardiaChat'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F1F1F),
        actions: [
          // أيقونة لمراقبة حالة الاتصال بالسحاب
          StreamBuilder<void>(
            stream: _firestore.snapshotsInSync(),
            builder: (context, _) => Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(Icons.cloud_done, color: Colors.green.withOpacity(0.7), size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(15),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    bool isMe = docs[index]['senderId'] == currentUserId;
                    String msg = _encryption.decrypt(docs[index]['text']);
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF0D47A1) : const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(msg, style: const TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Secure message...',
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
          ),
        ],
      ),
    );
  }
}
