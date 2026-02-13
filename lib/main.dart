import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // لا ننتظر أحداً.. اظهر الآن!
  runApp(const CardiaControlApp());
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase not ready yet");
  }
}

class CardiaControlApp extends StatelessWidget {
  const CardiaControlApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
      ),
      home: const MainControlScreen(),
    );
  }
}

class MainControlScreen extends StatelessWidget {
  const MainControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CardiaChat ✅", style: TextStyle(color: Colors.greenAccent)),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                "System Online\nReady for Secure Commands",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey, fontSize: 18),
              ),
            ),
          ),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionBtn(Icons.message, "Chat"),
          _actionBtn(Icons.security, "Encrypt"),
          _actionBtn(Icons.settings, "Control"),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: Colors.blueAccent.withOpacity(0.1), child: Icon(icon, color: Colors.blueAccent)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}
