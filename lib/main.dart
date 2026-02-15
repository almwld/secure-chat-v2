import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const CardiaSatellite());

class CardiaSatellite extends StatelessWidget {
  const CardiaSatellite({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF010A01), // لون أخضر عسكري غامق
        primaryColor: Colors.greenAccent,
      ),
      home: const CalculatorDecoy(),
    );
  }
}

// --- واجهة التمويه ---
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

// --- المحطة الفضائية (Satellite Terminal) ---
class SatelliteTerminal extends StatefulWidget {
  const SatelliteTerminal({super.key});
  @override
  State<SatelliteTerminal> createState() => _SatelliteTerminalState();
}

class _SatelliteTerminalState extends State<SatelliteTerminal> {
  bool _isUplink = false;
  double _azimuth = 145.0;

  void _triggerUplink() {
    setState(() => _isUplink = true);
    Timer(const Duration(seconds: 3), () => setState(() => _isUplink = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SATELLITE UPLINK ACTIVE", style: TextStyle(fontSize: 10, letterSpacing: 2)),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildCompassView(),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.greenAccent.withOpacity(0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("> INITIALIZING NTN PROTOCOL...", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                  const Text("> SEARCHING FOR ORBITAL NODE...", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                  if (!_isUplink) const Text("> STATUS: STANDBY", style: TextStyle(color: Colors.amber, fontSize: 10)),
                  if (_isUplink) const Text("> STATUS: DATA BURST TRANSMITTING...", style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                  const Spacer(),
                  const Text("LAST MESSAGE RECEIVED:", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const Text("COORD: 15.35N, 44.20E | TX_SUCCESS", style: TextStyle(color: Colors.greenAccent)),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCompassView() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent, width: 2)),
      child: Center(
        child: Icon(Icons.navigation, size: 80, color: Colors.greenAccent, angle: _azimuth),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: _triggerUplink, style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.2)), child: const Text("TX BURST")),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.2)), child: const Text("SCRAMBLE")),
        ],
      ),
    );
  }
}
