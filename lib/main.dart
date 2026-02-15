import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const CardiaSatellite());

class CardiaSatellite extends StatelessWidget {
  const CardiaSatellite({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF010A01),
        primaryColor: Colors.greenAccent,
      ),
      home: const CalculatorDecoy(),
    );
  }
}

// --- واجهة التمويه (الآلة الحاسبة) ---
class CalculatorDecoy extends StatefulWidget {
  const CalculatorDecoy({super.key});
  @override
  State<CalculatorDecoy> createState() => _CalculatorDecoyState();
}

class _CalculatorDecoyState extends State<CalculatorDecoy> {
  String _input = "0";
  void _onKey(String v) {
    setState(() {
      if (v == "C") _input = "0";
      else if (_input == "0") _input = v;
      else _input += v;
      if (_input == "7391") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const SatelliteTerminal()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container(alignment: Alignment.bottomRight, padding: const EdgeInsets.all(30),
            child: Text(_input, style: const TextStyle(fontSize: 50, fontFamily: 'monospace', color: Colors.greenAccent)))),
          _buildPad(),
        ],
      ),
    );
  }

  Widget _buildPad() {
    var k = ["7","8","9","/", "4","5","6","*", "1","2","3","-", "C","0","=","+"];
    return GridView.builder(shrinkWrap: true, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: k.length, itemBuilder: (c, i) => TextButton(onPressed: () => _onKey(k[i]), child: Text(k[i], style: const TextStyle(fontSize: 24, color: Colors.greenAccent))));
  }
}

// --- المحطة الفضائية والخزنة الاستخباراتية ---
class SatelliteTerminal extends StatefulWidget {
  const SatelliteTerminal({super.key});
  @override
  State<SatelliteTerminal> createState() => _SatelliteTerminalState();
}

class _SatelliteTerminalState extends State<SatelliteTerminal> {
  int _tab = 0;
  List<File> _secretPhotos = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureIntel() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _secretPhotos.add(File(photo.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? "SATELLITE TERMINAL" : "INTEL VAULT", style: const TextStyle(fontSize: 10, letterSpacing: 2)),
        backgroundColor: Colors.black,
      ),
      body: _tab == 0 ? _buildTerminal() : _buildVault(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.settings_input_antenna), label: "Uplink"),
          BottomNavigationBarItem(icon: Icon(Icons.visibility_off), label: "Intel"),
        ],
      ),
      floatingActionButton: _tab == 1 ? FloatingActionButton(
        onPressed: _captureIntel,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildTerminal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Icon(Icons.radar, size: 100, color: Colors.greenAccent)),
          const SizedBox(height: 30),
          const Text("> NODE CONNECTED: ORBIT_X1", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
          const Text("> ENCRYPTION: MIL-SPEC AES-256", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
          const Spacer(),
          ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)), child: const Center(child: Text("ESTABLISH QUANTUM LINK"))),
        ],
      ),
    );
  }

  Widget _buildVault() {
    return _secretPhotos.isEmpty 
      ? const Center(child: Text("NO CLASSIFIED DATA FOUND", style: TextStyle(color: Colors.grey)))
      : GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: _secretPhotos.length,
          itemBuilder: (c, i) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_secretPhotos[i], fit: BoxFit.cover),
          ),
        );
  }
}
