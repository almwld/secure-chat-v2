import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';

void main() async {
  // تفعيل الربط مع النظام
  WidgetsFlutterBinding.ensureInitialized();
  
  // تشغيل التطبيق فوراً وعدم انتظار Firebase لمنع الشاشة البيضاء
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ChatScreen(),
  ));

  // بدء Firebase في الخلفية
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase init error: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("CardiaChat ✅"),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  itemCount: snap.data!.docs.length,
                  itemBuilder: (context, i) {
                    var data = snap.data!.docs[i];
                    return ListTile(
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_enc.decrypt(data['text'] ?? ""), style: const TextStyle(color: Colors.white)),
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
      padding: const EdgeInsets.all(8.0),
      color: const Color(0xFF1F1F1F),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _con, style: const TextStyle(color: Colors.white))),
          IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () {
            if(_con.text.isNotEmpty) {
              FirebaseFirestore.instance.collection('messages').add({
                'text': _enc.encrypt(_con.text),
                'createdAt': FieldValue.serverTimestamp(),
                'senderId': 'User_A'
              });
              _con.clear();
            }
          }),
        ],
      ),
    );
  }
}
