import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'security.dart';

void main() => runApp(const CardiaCloakApp());

class CardiaCloakApp extends StatelessWidget {
  const CardiaCloakApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF080808)),
      home: const CloakChatScreen(),
    );
  }
}

class CloakChatScreen extends StatefulWidget {
  const CloakChatScreen({super.key});
  @override
  State<CloakChatScreen> createState() => _CloakChatScreenState();
}

class _CloakChatScreenState extends State<CloakChatScreen> {
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
    String? data = _prefs.getString('cloak_db');
    if (data != null) {
      setState(() => _messages = List<Map<String, dynamic>>.from(json.decode(data)));
    }
  }

  _sendMessage() async {
    if (_con.text.isEmpty) return;
    final msg = {
      'payload': _enc.encrypt(_con.text),
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'isMe': true
    };
    setState(() => _messages.insert(0, msg));
    _con.clear();
    await _prefs.setString('cloak_db', json.encode(_messages));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CARDIA CLOAK", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, color: Colors.cyanAccent)),
        backgroundColor: Colors.black,
        actions: [const Icon(Icons.remove_red_eye_outlined), const SizedBox(width: 15)],
      ),
      body: Column(
        children: [
          Expanded(child: _buildChatList()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        var m = _messages[i];
        String realText = _enc.decrypt(m['payload']);
        String coverText = _enc.getCoverOnly(m['payload']);
        return _bubble(realText, coverText, m['isMe'], m['time']);
      },
    );
  }

  Widget _bubble(String real, String cover, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyanAccent.withOpacity(0.08) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(real, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 5),
            Text("Cloak: $cover", style: const TextStyle(color: Colors.white24, fontSize: 9, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: TextField(
        controller: _con,
        decoration: InputDecoration(
          hintText: "Write undercover...",
          suffixIcon: IconButton(icon: const Icon(Icons.send, color: Colors.cyanAccent), onPressed: _sendMessage),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
