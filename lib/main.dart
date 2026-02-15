import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const CardiaUltimate());

class CardiaUltimate extends StatelessWidget {
  const CardiaUltimate({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF000500)),
      home: const CalculatorDecoy(),
    );
  }
}

class CalculatorDecoy extends StatefulWidget {
  const CalculatorDecoy({super.key});
  @override
  State<CalculatorDecoy> createState() => _CalculatorDecoyState();
}

class _CalculatorDecoyState extends State<CalculatorDecoy> {
  String _input = "";

  void _onKey(String v) {
    HapticFeedback.lightImpact(); // اهتزاز خفيف عند الضغط
    setState(() {
      if (v == "C") {
        _input = "";
      } else {
        _input += v;
      }

      // 🔑 التحقق الفوري من الكود السري
      if (_input == "7391") {
        HapticFeedback.vibrate(); // اهتزاز قوي عند النجاح
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (c) => const QuantumDashboard())
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(40),
              child: Text(
                _input.isEmpty ? "0" : _input,
                style: const TextStyle(fontSize: 80, color: Colors.greenAccent, fontWeight: FontWeight.w200),
              ),
            ),
          ),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    var keys = ["7","8","9","/", "4","5","6","*", "1","2","3","-", "C","0","=","+"];
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: keys.length,
      itemBuilder: (c, i) => InkWell(
        onTap: () => _onKey(keys[i]),
        child: Center(
          child: Text(keys[i], style: const TextStyle(fontSize: 30, color: Colors.greenAccent)),
        ),
      ),
    );
  }
}

// --- واجهة لوحة التحكم (التي ظهرت في صورك) ---
class QuantumDashboard extends StatefulWidget {
  const QuantumDashboard({super.key});
  @override
  State<QuantumDashboard> createState() => _QuantumDashboardState();
}

class _QuantumDashboardState extends State<QuantumDashboard> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tab == 0 ? _buildRadar() : (_tab == 1 ? _buildVault() : _buildConfig()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: "Radar"),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: "Vault"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Config"),
        ],
      ),
    );
  }

  Widget _buildRadar() => const Center(child: Text("SCANNING FOR NODES...", style: TextStyle(color: Colors.cyanAccent)));
  Widget _buildVault() => ListView.builder(
    itemCount: 5,
    itemBuilder: (c, i) => ListTile(
      leading: const Icon(Icons.lock_outline),
      title: Text("Encrypted Node #$i"),
      subtitle: const Text("Last burst: 2 mins ago"),
    ),
  );
  Widget _buildConfig() => const Center(child: Text("SYSTEM PARAMETERS"));
}
