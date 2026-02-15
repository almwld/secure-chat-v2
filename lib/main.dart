import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const CardiaOS());
}

class CardiaOS extends StatelessWidget {
  const CardiaOS({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF00080F),
        primaryColor: Colors.cyanAccent,
      ),
      home: const CalculatorDecoy(),
    );
  }
}

// --- المرحلة 1: التمويه (آلة حاسبة) ---
class CalculatorDecoy extends StatefulWidget {
  const CalculatorDecoy({super.key});
  @override
  State<CalculatorDecoy> createState() => _CalculatorDecoyState();
}

class _CalculatorDecoyState extends State<CalculatorDecoy> {
  String _display = "0";
  void _onPressed(String val) {
    setState(() {
      if (val == "C") _display = "0";
      else if (_display == "0") _display = val;
      else _display += val;
      
      if (_display == "7391") { // الكود السري للدخول
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainVault()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(padding: const EdgeInsets.all(30), alignment: Alignment.bottomRight,
            child: Text(_display, style: const TextStyle(fontSize: 60, color: Colors.white))),
          GridView.count(
            shrinkWrap: true, crossAxisCount: 4,
            children: ["7","8","9","/","4","5","6","*","1","2","3","-","C","0","=","+"].map((key) => 
              TextButton(onPressed: () => _onPressed(key), child: Text(key, style: const TextStyle(fontSize: 24, color: Colors.cyanAccent)))
            ).toList(),
          ),
        ],
      ),
    );
  }
}

// --- المرحلة 2: الخزنة الرئيسية (الرادار والدردشة) ---
class MainVault extends StatefulWidget {
  const MainVault({super.key});
  @override
  State<MainVault> createState() => _MainVaultState();
}

class _MainVaultState extends State<MainVault> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [const RadarScreen(), const ChatList(), const SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: "Radar"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Vault"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Config"),
        ],
      ),
    );
  }
}

// --- شاشة الرادار (Mesh Network) ---
class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.radio, size: 100, color: Colors.cyanAccent),
          const SizedBox(height: 20),
          const Text("SCANNING FOR NODES...", style: TextStyle(letterSpacing: 3)),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.cyanAccent),
        ],
      ),
    );
  }
}

// --- قائمة الدردشة ---
class ChatList extends StatelessWidget {
  const ChatList({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (c, i) => ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.lock_outline)),
        title: Text("Encrypted Node #$i"),
        subtitle: const Text("Last burst: 2 mins ago"),
        onTap: () {},
      ),
    );
  }
}

// --- شاشة الإعدادات ---
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("SYSTEM PARAMETERS", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        SwitchListTile(title: const Text("DNS Turbo Mode"), value: true, onChanged: (v){}),
        SwitchListTile(title: const Text("Stealth Protocol"), value: true, onChanged: (v){}),
        const Divider(),
        ListTile(title: const Text("Wipe All Data"), textColor: Colors.red, leading: const Icon(Icons.delete, color: Colors.red), onTap: (){}),
      ],
    );
  }
}
