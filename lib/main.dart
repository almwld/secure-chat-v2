import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';

void main() => runApp(const CardiaGodMode());

class CardiaGodMode extends StatelessWidget {
  const CardiaGodMode({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF00050A)),
      home: const AuthGate(),
    );
  }
}

// --- بوابة الأمان الحيوي ---
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _authenticate() async {
    bool authenticated = await auth.authenticate(
      localizedReason: 'Scan Fingerprint to Unlock Vault',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (authenticated) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const CyberDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 100, color: Colors.cyanAccent),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              child: const Text("UNLOCK WITH BIOMETRICS", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- لوحة التحكم السيبرانية الجديدة ---
class CyberDashboard extends StatefulWidget {
  const CyberDashboard({super.key});
  @override
  State<CyberDashboard> createState() => _CyberDashboardState();
}

class _CyberDashboardState extends State<CyberDashboard> {
  int _nodesFound = 0;
  bool _isScanning = false;

  void _startRadar() {
    setState(() => _isScanning = true);
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _nodesFound = 3; // محاكاة العثور على أجهزة
        _isScanning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NODE RADAR ACTIVE")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildRadarView(),
          Expanded(
            child: ListView.builder(
              itemCount: _nodesFound,
              itemBuilder: (c, i) => ListTile(
                leading: const Icon(Icons.router, color: Colors.greenAccent),
                title: Text("Active Node #00$i"),
                subtitle: const Text("DNS Tunnel: Latency 40ms"),
                trailing: const Icon(Icons.bolt, color: Colors.magentaAccent),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startRadar,
        child: Icon(_isScanning ? Icons.sync : Icons.radar),
      ),
    );
  }

  Widget _buildRadarView() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.cyanAccent, width: 2),
      ),
      child: Center(
        child: _isScanning 
          ? const CircularProgressIndicator(color: Colors.cyanAccent)
          : const Icon(Icons.radio, size: 50, color: Colors.cyanAccent),
      ),
    );
  }
}
