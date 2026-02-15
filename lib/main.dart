import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'security.dart';

void main() => runApp(const CardiaOS());

class CardiaOS extends StatelessWidget {
  const CardiaOS({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF00050A),
        primaryColor: Colors.cyanAccent,
      ),
      home: const CyberLogin(),
    );
  }
}

// 1. شاشة الدخول (Gate)
class CyberLogin extends StatefulWidget {
  const CyberLogin({super.key});
  @override
  State<CyberLogin> createState() => _CyberLoginState();
}

class _CyberLoginState extends State<CyberLogin> {
  final TextEditingController _pin = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            const Text("SECURE ACCESS", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _pin,
                obscureText: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(letterSpacing: 10, color: Colors.cyanAccent),
                onChanged: (v) {
                  if (v == "1234") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainDashboard()));
                  if (v == "9999") _pin.clear(); // منطق المسح هنا
                },
                decoration: const InputDecoration(hintText: "PIN", border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. لوحة التحكم الرئيسية (Dashboard)
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final EncryptionService _enc = EncryptionService();
  final TextEditingController _msgCon = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTunneling = false;
  double _load = 0.0;

  // محرك الإرسال النفقي السريع
  Future<void> _sendData(String text) async {
    String secret = _enc.encrypt(text);
    setState(() {
       _messages.insert(0, {'msg': text, 'isMe': true, 'time': DateFormat('HH:mm').format(DateTime.now())});
       _load = 0.1;
    });

    if (_isTunneling) {
      // إرسال متوازي (Turbo)
      List<Future> burst = [];
      for (int i = 0; i < 5; i++) {
        burst.add(InternetAddress.lookup("${i}_${secret.substring(0, 5)}.dns.local"));
      }
      await Future.wait(burst).catchError((e) => []);
    }
    
    setState(() => _load = 0.0);
    _msgCon.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CARDIA ULTIMATE", style: TextStyle(fontSize: 14)),
        actions: [
          const Icon(Icons.bolt, size: 16),
          Switch(value: _isTunneling, activeColor: Colors.magentaAccent, onChanged: (v) => setState(() => _isTunneling = v)),
        ],
      ),
      body: Column(
        children: [
          if (_load > 0) const LinearProgressIndicator(color: Colors.cyanAccent),
          Expanded(child: _buildChatList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        return Align(
          alignment: m['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: _isTunneling ? Colors.magentaAccent : Colors.cyanAccent, width: 0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(m['msg']),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.black,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _msgCon,
              decoration: const InputDecoration(hintText: "Type via Tunnel...", border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.cyanAccent),
            onPressed: () => _sendData(_msgCon.text),
          ),
        ],
      ),
    );
  }
}
