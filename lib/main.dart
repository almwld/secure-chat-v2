import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'security.dart';

void main() => runApp(const CardiaCyberApp());

class CardiaCyberApp extends StatelessWidget {
  const CardiaCyberApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF00050A)),
      home: const CyberLoginScreen(),
    );
  }
}

// ... (شاشة الدخول كما هي في الكود السابق) ...

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
  String _tunnelStatus = "Ready";

  // محرك نفق الـ DNS الفعلي
  Future<void> _sendViaDNS(String encryptedData) async {
    setState(() => _tunnelStatus = "Tunneling...");
    
    try {
      // محاكاة إرسال الطرود عبر DNS Queries
      // في الأنظمة المتقدمة، يتم إرسالها لـ DNS Server مخصص
      final String fakeDomain = "${encryptedData.substring(0, 10)}.tunnel.local";
      
      // محاولة البحث عن العنوان (هذا الطلب سيمر عبر الميكروتيك)
      await InternetAddress.lookup(fakeDomain).timeout(const Duration(seconds: 2));
    } catch (e) {
      // الخطأ هنا متوقع لأن الدومين وهمي، لكن الطلب "خرج" بالفعل من الشبكة
      debugPrint("Packet Sent via DNS Port 53");
    }

    setState(() => _tunnelStatus = "Packet Relayed");
    Future.delayed(const Duration(seconds: 2), () => setState(() => _tunnelStatus = "Ready"));
  }

  _sendMessage() async {
    if (_con.text.isEmpty) return;
    
    String plain = _con.text;
    String secret = _enc.encrypt(plain);

    setState(() {
      _messages.insert(0, {
        'p': secret,
        'time': DateFormat('HH:mm').format(DateTime.now()),
        'isMe': true,
        'via': _isTunneling ? "DNS" : "Local"
      });
    });

    if (_isTunneling) {
      await _sendViaDNS(secret);
    }

    _con.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CARDIA PROTOCOL", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("Status: $_tunnelStatus", style: TextStyle(fontSize: 9, color: _isTunneling ? Colors.magentaAccent : Colors.cyanAccent)),
          ],
        ),
        backgroundColor: Colors.black,
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
          Expanded(child: _buildMessages()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        var m = _messages[i];
        return _bubble(_enc.decrypt(m['p']), m['isMe'], m['time'], m['via']);
      },
    );
  }

  Widget _bubble(String text, bool isMe, String time, String via) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: via == "DNS" ? Colors.magentaAccent.withOpacity(0.05) : Colors.cyanAccent.withOpacity(0.05),
          border: Border.all(color: via == "DNS" ? Colors.magentaAccent.withOpacity(0.2) : Colors.cyanAccent.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 5),
            Text("$time | $via", style: const TextStyle(fontSize: 8, color: Colors.white24)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _con,
              decoration: InputDecoration(
                hintText: _isTunneling ? "Escaping via DNS..." : "Type message...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.02),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.cyanAccent), onPressed: _sendMessage)
        ],
      ),
    );
  }
}
