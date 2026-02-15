import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'security.dart';

void main() => runApp(const CardiaUltimateApp());

class CardiaUltimateApp extends StatelessWidget {
  const CardiaUltimateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF00050A)),
      home: const CyberLoginScreen(),
    );
  }
}

// ... (شاشة الدخول PIN كما هي) ...

class CyberChat extends StatefulWidget {
  const CyberChat({super.key});
  @override
  State<CyberChat> createState() => _CyberChatState();
}

class _CyberChatState extends State<CyberChat> {
  final EncryptionService _enc = EncryptionService();
  final TextEditingController _con = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isTunneling = false;
  String _tunnelStatus = "IDLE";
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // تشغيل المستمع للبحث عن رسائل قادمة كل 30 ثانية
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (t) => _listenForMessages());
  }

  @override
  void dispose() { _updateTimer?.cancel(); super.dispose(); }

  // 1. المُرسل: دفع البيانات عبر DNS TXT Query
  Future<void> _pushViaDNS(String secret) async {
    setState(() => _tunnelStatus = "PUSHING...");
    try {
      // محاكاة إرسال الطرد - نستخدم دومين فريد لكل رسالة
      String dnsPacket = "${secret.substring(0, min(secret.length, 20))}.node.local";
      await InternetAddress.lookup(dnsPacket).timeout(const Duration(seconds: 2));
    } catch (e) { 
      debugPrint("Packet Egress via Port 53"); 
    }
    setState(() => _tunnelStatus = "SENT");
  }

  // 2. المُستقبل: البحث عن رسائل في الهواء الرقمي
  Future<void> _listenForMessages() async {
    if (!_isTunneling) return;
    setState(() => _tunnelStatus = "SCANNING...");
    
    try {
      // هنا نقوم بالبحث عن سجلات TXT (محاكاة)
      // في النسخة الكاملة، يتم الربط مع API DNS مجاني
      await Future.delayed(const Duration(seconds: 2)); 
    } catch (e) { }
    
    setState(() => _tunnelStatus = "STABLE");
  }

  int min(int a, int b) => a < b ? a : b;

  _handleSend() async {
    if (_con.text.isEmpty) return;
    String plain = _con.text;
    String secret = _enc.encrypt(plain);

    setState(() {
      _messages.insert(0, {'p': secret, 'time': DateFormat('HH:mm').format(DateTime.now()), 'isMe': true, 'via': _isTunneling ? "TUNNEL" : "LOCAL"});
    });

    if (_isTunneling) await _pushViaDNS(secret);
    _con.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CARDIA CORE", style: TextStyle(fontSize: 14, color: Colors.cyanAccent)),
            Text("LINK: $_tunnelStatus", style: TextStyle(fontSize: 9, color: Colors.white38)),
          ],
        ),
        actions: [
          Switch(
            value: _isTunneling,
            activeColor: Colors.magentaAccent,
            onChanged: (v) => setState(() => _isTunneling = v),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildList()),
          _inputArea(),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        var m = _messages[i];
        return _chatBubble(_enc.decrypt(m['p']), m['isMe'], m['time'], m['via']);
      },
    );
  }

  Widget _chatBubble(String text, bool isMe, String time, String via) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: via == "TUNNEL" ? Colors.magentaAccent.withOpacity(0.05) : Colors.cyanAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: via == "TUNNEL" ? Colors.magentaAccent.withOpacity(0.2) : Colors.cyanAccent.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Colors.white)),
            Text("$time [$via]", style: const TextStyle(fontSize: 8, color: Colors.white24)),
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
                hintText: _isTunneling ? "Tunnel Active..." : "Local Mode...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.02),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.bolt, color: Colors.cyanAccent), onPressed: _handleSend),
        ],
      ),
    );
  }
}
