import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';

void main() => runApp(const CardiaOS());

class CardiaOS extends StatelessWidget {
  const CardiaOS({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF010A01)),
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
  String _input = "0";
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _authenticate(bool isPanic) async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Secure Access Verification',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (authenticated) {
        if (isPanic) {
          exit(0); // هنا نضع كود المسح لاحقاً
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const SecureTerminal()));
        }
      }
    } catch (e) {
      // في حال عدم دعم البصمة
    }
  }

  void _onKey(String v) {
    setState(() {
      if (v == "C") _input = "0";
      else if (_input == "0") _input = v;
      else _input += v;
      if (_input == "7391") _authenticate(false);
      if (_input == "999") _authenticate(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container(alignment: Alignment.bottomRight, padding: const EdgeInsets.all(30),
            child: Text(_input, style: const TextStyle(fontSize: 50, color: Colors.greenAccent)))),
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

class SecureTerminal extends StatelessWidget {
  const SecureTerminal({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("SATELLITE LINK ACTIVE")), body: const Center(child: Text("SECURE DATA MODE")));
  }
}
