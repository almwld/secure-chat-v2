import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'security.dart';
import 'storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const CardiaMasterpiece());
}

class CardiaMasterpiece extends StatelessWidget {
  const CardiaMasterpiece({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF00080F),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent, brightness: Brightness.dark),
      ),
      home: const MainVault(),
    );
  }
}

class MainVault extends StatefulWidget {
  const MainVault({super.key});
  @override
  State<MainVault> createState() => _MainVaultState();
}

class _MainVaultState extends State<MainVault> with SingleTickerProviderStateMixin {
  bool _isTurbo = false;
  final TextEditingController _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            _buildStatusNode(),
            const SizedBox(width: 10),
            const Text("CARDIA ULTIMATE", style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(_isTurbo ? Icons.bolt : Icons.shutter_speed, color: _isTurbo ? Colors.magentaAccent : Colors.cyanAccent), 
          onPressed: () => setState(() => _isTurbo = !_isTurbo)),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              _isTurbo ? Colors.magentaAccent.withOpacity(0.05) : Colors.cyanAccent.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildInputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusNode() {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isTurbo ? Colors.magentaAccent : Colors.cyanAccent,
        boxShadow: [BoxShadow(color: _isTurbo ? Colors.magentaAccent : Colors.cyanAccent, blurRadius: 10)],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, i) => _chatBubble("Sample Message", true),
      itemCount: 5,
    );
  }

  Widget _chatBubble(String text, bool isMe) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: "SECURE TRANSMISSION...",
          fillColor: Colors.white.withOpacity(0.02),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          suffixIcon: const Icon(Icons.send, color: Colors.cyanAccent),
        ),
      ),
    );
  }
}
