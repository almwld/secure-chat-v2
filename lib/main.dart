import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'security.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CardiaOfflineApp());
}

class CardiaOfflineApp extends StatelessWidget {
  const CardiaOfflineApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const ChatBase(),
    );
  }
}

class ChatBase extends StatefulWidget {
  const ChatBase({super.key});
  @override
  State<ChatBase> createState() => _ChatBaseState();
}

class _ChatBaseState extends State<ChatBase> {
  final EncryptionService _enc = EncryptionService();
  final TextEditingController _con = TextEditingController();
  List<Map<String, String>> _messages = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // تحميل الرسائل من ذاكرة الهاتف
  _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    String? saved = _prefs.getString('local_db');
    if (saved != null) {
      setState(() {
        _messages = List<Map<String, String>>.from(json.decode(saved).map((item) => Map<String, String>.from(item)));
      });
    }
  }

  // حفظ الرسالة مشفرة في ذاكرة الهاتف
  _sendMessage() async {
    if (_con.text.isEmpty) return;
    
    String time = DateFormat('hh:mm a').format(DateTime.now());
    String encryptedText = _enc.encrypt(_con.text);

    setState(() {
      _messages.insert(0, {
        'text': encryptedText,
        'time': time,
        'sender': 'Me'
      });
    });

    _con.clear();
    await _prefs.setString('local_db', json.encode(_messages));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CARDIA OFFLINE", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.redAccent), onPressed: () async {
            await _prefs.clear();
            setState(() => _messages = []);
          })
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                String plainText = _enc.decrypt(_messages[i]['text']!);
                return _bubble(plainText, _messages[i]['time']!);
              },
            ),
          ),
          _inputArea(),
        ],
      ),
    );
  }

  Widget _bubble(String text, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.cyanAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15).copyWith(bottomRight: Radius.zero),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _inputArea() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: "Vault message...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.cyanAccent,
            child: IconButton(icon: const Icon(Icons.send, color: Colors.black), onPressed: _sendMessage),
          )
        ],
      ),
    );
  }
}
