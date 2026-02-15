import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'security.dart';

void main() => runApp(const CardiaCyberApp());

class CardiaCyberApp extends StatelessWidget {
  const CardiaCyberApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF00050A),
        primaryColor: Colors.cyanAccent,
      ),
      home: const CyberLoginScreen(),
    );
  }
}

// شاشة دخول بتصميم سايبربانك
class CyberLoginScreen extends StatefulWidget {
  const CyberLoginScreen({super.key});
  @override
  State<CyberLoginScreen> createState() => _CyberLoginScreenState();
}

class _CyberLoginScreenState extends State<CyberLoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _pin = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00050A),
                  Color.lerp(Colors.blueGrey[900], Colors.cyan[900], _controller.value)!,
                  const Color(0xFF00050A),
                ],
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt, size: 100, color: Colors.cyanAccent),
              const Text("CARDIA OS v2.0", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 5, color: Colors.cyanAccent)),
              const SizedBox(height: 50),
              _buildPinField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 10)],
      ),
      child: TextField(
        controller: _pin,
        obscureText: true,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.cyanAccent, letterSpacing: 10),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: "PIN", border: InputBorder.none),
        onChanged: (v) {
          if (v == "1234") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const CyberChat()));
          if (v == "9999") _wipeData();
        },
      ),
    );
  }

  _wipeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SYSTEM PURGED")));
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ACCESS PROTOCOL", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildTunnelToggle(),
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

  Widget _buildTunnelToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isTunneling = !_isTunneling),
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _isTunneling ? Colors.magentaAccent : Colors.cyanAccent),
        ),
        child: Row(
          children: [
            Icon(Icons.vpn_lock, size: 14, color: _isTunneling ? Colors.magentaAccent : Colors.cyanAccent),
            const SizedBox(width: 5),
            Text(_isTunneling ? "DNS TUNNEL: ON" : "MESH MODE", style: TextStyle(fontSize: 10, color: _isTunneling ? Colors.magentaAccent : Colors.cyanAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        var m = _messages[i];
        return _cyberBubble(_enc.decrypt(m['p']), m['isMe'], m['time']);
      },
    );
  }

  Widget _cyberBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyanAccent.withOpacity(0.05) : Colors.white.withOpacity(0.02),
          border: Border.all(color: isMe ? Colors.cyanAccent.withOpacity(0.2) : Colors.white10),
          borderRadius: BorderRadius.circular(15).copyWith(bottomRight: Radius.zero),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(color: Colors.white24, fontSize: 9)),
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
                hintText: _isTunneling ? "Tunneling via Port 53..." : "Local Mesh...",
                fillColor: Colors.white.withOpacity(0.03),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.flash_on, color: _isTunneling ? Colors.magentaAccent : Colors.cyanAccent),
            onPressed: () {
              if (_con.text.isEmpty) return;
              setState(() {
                _messages.insert(0, {
                  'p': _enc.encrypt(_con.text),
                  'time': DateFormat('HH:mm').format(DateTime.now()),
                  'isMe': true
                });
              });
              _con.clear();
            },
          ),
        ],
      ),
    );
  }
}
