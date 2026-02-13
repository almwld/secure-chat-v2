import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تشغيل Firebase في الخلفية دون انتظار (Non-blocking)
  Firebase.initializeApp().then((_) {
    print("Firebase Connected!");
  }).catchError((e) {
    print("Offline Mode: $e");
  });

  runApp(const SecureChatApp());
}

class SecureChatApp extends StatelessWidget {
  const SecureChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
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
      
      // Firestore يحفظ البيانات محلياً ويرسلها تلقائياً عند عودة الإنترنت
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
        title: const Text('🔐 CardiaChat (Offline Ready)'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                // حتى لو لم تكتمل البيانات من السحاب، سيعرض ما هو مخزن محلياً
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: Text("Connecting..."));
                }
                
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    bool isMe = doc['senderId'] == currentUserId;
                    String decryptedText = _encryption.decrypt(doc['text']);
                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[900] : Colors.grey[800],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(decryptedText),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: const Color(0xFF1F1F1F),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Type a message...'),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
