import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'security.dart';

void main() => runApp(const CardiaHybridApp());

class CardiaHybridApp extends StatelessWidget {
  const CardiaHybridApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF050505)),
      home: const HybridChatScreen(),
    );
  }
}

class HybridChatScreen extends StatefulWidget {
  const HybridChatScreen({super.key});
  @override
  State<HybridChatScreen> createState() => _HybridChatScreenState();
}

class _HybridChatScreenState extends State<HybridChatScreen> {
  final EncryptionService _enc = EncryptionService();
  final TextEditingController _con = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  _initStorage() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMessages();
  }

  _loadMessages() {
    String? data = _prefs.getString('dtn_queue');
    if (data != null) {
      setState(() => _messages = List<Map<String, dynamic>>.from(json.decode(data)));
    }
  }

  _processMessage() async {
    if (_con.text.isEmpty) return;

    final newMessage = {
      'id': const Uuid().v4(),
      'text': _enc.encrypt(_con.text),
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'status': 'Stored', // Stored -> In-Transit -> Delivered
      'type': 'outgoing'
    };

    setState(() => _messages.insert(0, newMessage));
    _con.clear();
    await _prefs.setString('dtn_queue', json.encode(_messages));
    
    // محاكاة البحث عن "مسافر" أو "شبكة DNS" بعد ثوانٍ
    Future.delayed(const Duration(seconds: 4), () {
      _simulateTransport(newMessage['id']!);
    });
  }

  _simulateTransport(String id) async {
    int index = _messages.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      setState(() => _messages[index]['status'] = 'In-Transit');
      await _prefs.setString('dtn_queue', json.encode(_messages));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CARDIA HYBRID", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        actions: [
          const Icon(Icons.router, color: Colors.orangeAccent), // رمز الـ DNS Tunneling
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildList()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      reverse: true,
      physics: const BouncingScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        var msg = _messages[i];
        String plain = _enc.decrypt(msg['text']);
        return _chatBubble(plain, msg['time'], msg['status']);
      },
    );
  }

  Widget _chatBubble(String text, String time, String status) {
    Color statusColor = status == 'Stored' ? Colors.grey : (status == 'In-Transit' ? Colors.orangeAccent : Colors.greenAccent);
    
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15).copyWith(bottomRight: Radius.zero),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                const SizedBox(width: 5),
                Icon(status == 'Stored' ? Icons.access_time : Icons.directions_bus, size: 10, color: statusColor),
                const SizedBox(width: 3),
                Text(status, style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: "Send via Hybrid Link...",
                fillColor: Colors.white.withOpacity(0.05),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.cyanAccent,
            child: IconButton(icon: const Icon(Icons.send, color: Colors.black), onPressed: _processMessage),
          ),
        ],
      ),
    );
  }
}
