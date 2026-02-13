import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تشغيل آمن: لا ننتظر الاتصال لتجنب الشاشة البيضاء
  Firebase.initializeApp().then((_) {
    debugPrint("Firebase initialized");
  }).catchError((e) {
    debugPrint("Offline mode: $e");
  });

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
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
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
  final String currentUserId = 'User_A';

  void _updateTypingStatus(bool typing) {
    // محاولة تحديث الحالة فقط إذا كان هناك اتصال
    try {
      _firestore.collection('status').doc(currentUserId).set({
        'isTyping': typing,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // تجاهل الخطأ في وضع الأوفلاين
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      String encryptedText = _encryption.encrypt(_controller.text);
      _firestore.collection('messages').add({
        'text': encryptedText,
        'senderId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _controller.clear();
      _updateTypingStatus(false);
      setState(() => isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CardiaChat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('status').doc('User_B').snapshots(),
              builder: (context, snap) {
                // عرض الحالة الافتراضية إذا لم تتوفر بيانات
                if (!snap.hasData || !snap.data!.exists) {
                   return const Text('offline', style: TextStyle(fontSize: 12, color: Colors.grey));
                }
                bool typing = snap.data!.get('isTyping') ?? false;
                return Text(
                  typing ? 'typing...' : 'online', 
                  style: TextStyle(fontSize: 12, color: typing ? Colors.greenAccent : Colors.blueGrey)
                );
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 4,
      ),
      body: Container(
        // استخدام تدرج لوني بدلاً من الصورة لتجنب مشاكل التحميل
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF121212),
              const Color(0xFF1E1E2C),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  // عرض مؤشر تحميل فقط إذا لم تكن هناك بيانات مخزنة محلياً
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final docs = snapshot.data?.docs ?? [];
                  
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      bool isMe = data['senderId'] == currentUserId;
                      String msg = _encryption.decrypt(data['text'] ?? '');
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: isMe 
                              ? const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]) 
                              : LinearGradient(colors: [Colors.grey[800]!, Colors.grey[700]!]),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))
                            ],
                          ),
                          child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 16)),
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
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1F1F),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_rounded, color: Colors.blueAccent), 
            onPressed: () {
               // سنفعل زر الصور في الخطوة القادمة
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image feature coming next!")));
            }
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (val) {
                bool typing = val.trim().isNotEmpty;
                if (typing != isTyping) {
                  setState(() => isTyping = typing);
                  _updateTypingStatus(typing);
                }
              },
              decoration: InputDecoration(
                hintText: 'Type securely...',
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF1976D2),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
