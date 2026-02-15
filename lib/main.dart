import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050505),
        primaryColor: Colors.cyanAccent,
      ),
      home: const MeshChatScreen(),
    );
  }
}

class MeshChatScreen extends StatefulWidget {
  const MeshChatScreen({super.key});
  @override
  State<MeshChatScreen> createState() => _MeshChatScreenState();
}

class _MeshChatScreenState extends State<MeshChatScreen> {
  final EncryptionService _enc = EncryptionService();
  final TextEditingController _con = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  List<String> _nearbyNodes = []; // قائمة الجيران المكتشفين
  bool _isScanning = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  _initApp() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMessages();
    _startRadar();
  }

  // تشغيل رادار البحث عن جيران (محاكاة P2P Discovery)
  _startRadar() {
    setState(() => _isScanning = true);
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // محاكاة اكتشاف جهاز قريب عند الاتصال بنفس الميكروتيك
          if (_nearbyNodes.length < 3) {
            _nearbyNodes.add("Node-${const Uuid().v4().substring(0, 4)}");
          }
        });
      }
    });
  }

  _loadMessages() {
    String? data = _prefs.getString('mesh_db');
    if (data != null) {
      setState(() => _messages = List<Map<String, dynamic>>.from(json.decode(data)));
    }
  }

  _sendMessage() async {
    if (_con.text.isEmpty) return;

    final msg = {
      'id': const Uuid().v4(),
      'text': _enc.encrypt(_con.text),
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'status': _nearbyNodes.isEmpty ? 'Stored' : 'Relayed',
      'from': 'Me'
    };

    setState(() => _messages.insert(0, msg));
    _con.clear();
    await _prefs.setString('mesh_db', json.encode(_messages));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CARDIA MESH", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _buildRadarBar(),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildChatList()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildRadarBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      color: Colors.cyanAccent.withOpacity(0.05),
      child: Row(
        children: [
          Icon(Icons.radar, size: 16, color: _isScanning ? Colors.cyanAccent : Colors.grey),
          const SizedBox(width: 10),
          Text(
            _nearbyNodes.isEmpty ? "Scanning for nodes..." : "${_nearbyNodes.length} Nodes Nearby",
            style: TextStyle(fontSize: 12, color: Colors.cyanAccent.withOpacity(0.7)),
          ),
          const Spacer(),
          if (_nearbyNodes.isNotEmpty)
            const Icon(Icons.compare_arrows, size: 16, color: Colors.greenAccent),
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
        bool isMe = m['from'] == 'Me';
        return _bubble(_enc.decrypt(m['text']), isMe, m['status'], m['time']);
      },
    );
  }

  Widget _bubble(String text, bool isMe, String status, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyanAccent.withOpacity(0.1) : Colors.white10,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: status == 'Relayed' ? Colors.greenAccent.withOpacity(0.3) : Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: const TextStyle(fontSize: 9, color: Colors.white38)),
                const SizedBox(width: 5),
                Icon(status == 'Relayed' ? Icons.done_all : Icons.timer, size: 10, color: Colors.white38),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: "Broadcast to Mesh...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.cyanAccent),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
