import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'security.dart';

void main() => runApp(const CardiaUltimateApp());

class CardiaUltimateApp extends StatelessWidget {
  const CardiaUltimateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const SecureEntryScreen(),
    );
  }
}

class SecureEntryScreen extends StatefulWidget {
  const SecureEntryScreen({super.key});
  @override
  State<SecureEntryScreen> createState() => _SecureEntryScreenState();
}

class _SecureEntryScreenState extends State<SecureEntryScreen> {
  final TextEditingController _pin = TextEditingController();
  final String _emergencyPin = "9999"; // كلمة سر مسح البيانات
  final String _realPin = "1234";      // كلمة سر الدخول الحقيقي

  _verify() async {
    if (_pin.text == _emergencyPin) {
      // عملية الانتحار الرقمي
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _showDialog("System Reset", "All data has been wiped successfully.");
    } else if (_pin.text == _realPin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainVault()));
    } else {
      _showDialog("Error", "Access Denied.");
    }
    _pin.clear();
  }

  _showDialog(String title, String msg) {
    showDialog(context: context, builder: (c) => AlertDialog(title: Text(title), content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_moon, size: 80, color: Colors.cyanAccent),
              const SizedBox(height: 30),
              TextField(
                controller: _pin,
                obscureText: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Secure PIN",
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verify,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                child: const Text("UNLOCK VAULT", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainVault extends StatelessWidget {
  const MainVault({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CARDIA SECURE")),
      body: const Center(child: Text("Welcome to your hidden messages.")),
    );
  }
}
