import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تشغيل الواجهة أولاً لضمان عدم ظهور شاشة بيضاء
  runApp(const CardiaControlApp());
  
  // تهيئة النظام في الخلفية
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Init Error: $e");
  }
}

class CardiaControlApp extends StatelessWidget {
  const CardiaControlApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: Colors.blueAccent,
      ),
      home: const MainControlScreen(),
    );
  }
}

class MainControlScreen extends StatefulWidget {
  const MainControlScreen({super.key});
  @override
  State<MainControlScreen> createState() => _MainControlScreenState();
}

class _MainControlScreenState extends State<MainControlScreen> {
  final TextEditingController _msgController = TextEditingController();
  final EncryptionService _encryption = EncryptionService();
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    // فحص الجاهزية للربط مع فيربيس
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔐 Cardia Central Control"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          Icon(Icons.circle, color: _isReady ? Colors.green : Colors.red, size: 12),
          const SizedBox(width: 15),
        ],
      ),
      body: _isReady ? _buildChatInterface() : _buildLoadingScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainCenterAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blueAccent),
          SizedBox(height: 20),
          Text("Initializing System Control...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: Text("Waiting for data..."));
              
              return ListView.builder(
                reverse: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  String decrypted = _encryption.decrypt(doc['text'] ?? "");
                  bool isMe = doc['senderId'] == "Admin";

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[900] : Colors.grey[850],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(decrypted),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _inputBar(),
      ],
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: const InputDecoration(hintText: "Enter secure command...", border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: () {
              if (_msgController.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('messages').add({
                  'text': _encryption.encrypt(_msgController.text),
                  'senderId': "Admin",
                  'createdAt': FieldValue.serverTimestamp(),
                });
                _msgController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
