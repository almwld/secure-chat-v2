import 'package:flutter/material.dart';
import 'dart:convert';

void main() => runApp(const CardiaQuantum());

class CardiaQuantum extends StatelessWidget {
  const CardiaQuantum({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF00080F),
        colorScheme: const ColorScheme.dark(primary: Colors.cyanAccent),
      ),
      home: const CalculatorDecoy(),
    );
  }
}

// --- واجهة التمويه (آلة حاسبة حقيقية) ---
class CalculatorDecoy extends StatefulWidget {
  const CalculatorDecoy({super.key});
  @override
  State<CalculatorDecoy> createState() => _CalculatorDecoyState();
}

class _CalculatorDecoyState extends State<CalculatorDecoy> {
  String _input = "0";
  void _onKey(String val) {
    setState(() {
      if (val == "C") _input = "0";
      else if (_input == "0") _input = val;
      else _input += val;
      if (_input == "7391") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const QuantumVault()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container(alignment: Alignment.bottomRight, padding: const EdgeInsets.all(30),
            child: Text(_input, style: const TextStyle(fontSize: 70, fontWeight: FontWeight.w200)))),
          _buildPad(),
        ],
      ),
    );
  }

  Widget _buildPad() {
    var keys = ["7","8","9","/", "4","5","6","*", "1","2","3","-", "C","0","=","+"];
    return GridView.builder(
      shrinkWrap: true, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: keys.length, itemBuilder: (c, i) => TextButton(
        onPressed: () => _onKey(keys[i]),
        child: Text(keys[i], style: const TextStyle(fontSize: 25, color: Colors.cyanAccent))),
    );
  }
}

// --- الخزنة المتطورة (تفعيل التشفير والربط) ---
class QuantumVault extends StatefulWidget {
  const QuantumVault({super.key});
  @override
  State<QuantumVault> createState() => _QuantumVaultState();
}

class _QuantumVaultState extends State<QuantumVault> {
  bool _isLocked = true; // مفتاح قفل/فتح التشفير
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QUANTUM LINK: ACTIVE", style: TextStyle(fontSize: 12, letterSpacing: 2)),
        actions: [
          Row(children: [
            const Text("DECRYPT", style: TextStyle(fontSize: 10)),
            Switch(value: !_isLocked, activeColor: Colors.greenAccent, 
              onChanged: (v) => setState(() => _isLocked = !v)),
          ])
        ],
      ),
      body: _tab == 0 ? _buildMessages() : _buildRadar(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab, onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.security), label: "Vault"),
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: "Radar"),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    // محاكاة لرسالة مشفرة قادمة من هاتف آخر
    String rawData = "SGVsbG8gRnJvbSBPdGhlciBTaWRlID8="; 
    String decoded = utf8.decode(base64.decode(rawData));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          color: Colors.white10,
          child: ListTile(
            leading: Icon(_isLocked ? Icons.lock : Icons.lock_open, color: Colors.cyanAccent),
            title: const Text("Node: Alpha-Delta"),
            subtitle: Text(_isLocked ? rawData : decoded, 
              style: TextStyle(fontFamily: _isLocked ? 'monospace' : null, color: _isLocked ? Colors.grey : Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildRadar() {
    return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
  }
}
