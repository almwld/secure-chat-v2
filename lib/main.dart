import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'security.dart';
import 'storage.dart';

void main() => runApp(const CardiaOS());

class CardiaOS extends StatelessWidget {
  const CardiaOS({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF00050A)),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final EncryptionService _enc = EncryptionService();
  final LocalVault _vault = LocalVault();
  final TextEditingController _msgCon = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isTunneling = false;

  @override
  void initState() {
    super.initState();
    _loadHistory(); // تحميل الأرشيف عند فتح التطبيق
  }

  // تحميل الرسائل القديمة من الخزنة
  _loadHistory() async {
    final history = await _vault.getHistory();
    setState(() => _messages = history.reversed.toList());
  }

  _sendData(String text) async {
    if (text.isEmpty) return;
    
    final msg = {
      'msg': text,
      'isMe': true,
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'type': _isTunneling ? "TUNNEL" : "LOCAL"
    };

    // حفظ في الخزنة ثم التحديث في الواجهة
    await _vault.saveMessage(msg);
    setState(() => _messages.insert(0, msg));

    if (_isTunneling) {
       // محرك النفق التوربو
       InternetAddress.lookup("${text.length}_${_enc.encrypt(text)}.node.local").catchError((e)=>[]);
    }
    _msgCon.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VAULT ACTIVE", style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
        actions: [
          Switch(value: _isTunneling, activeColor: Colors.magentaAccent, onChanged: (v)=>setState(()=>_isTunneling=v))
        ],
      ),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final m = _messages[i];
              return ListTile(
                title: Align(
                  alignment: m['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: m['type'] == "TUNNEL" ? Colors.magentaAccent : Colors.cyanAccent, width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(m['msg']),
                  ),
                ),
                subtitle: Align(
                  alignment: m['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text("${m['time']} | ${m['type']}", style: const TextStyle(fontSize: 8)),
                ),
              );
            },
          )),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(child: TextField(controller: _msgCon, decoration: const InputDecoration(hintText: "Enter message..."))),
          IconButton(icon: const Icon(Icons.send, color: Colors.cyanAccent), onPressed: () => _sendData(_msgCon.text)),
        ],
      ),
    );
  }
}
