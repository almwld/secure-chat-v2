import 'package:flutter/material.dart';
import 'dart:async';
import 'security.dart';
import 'storage.dart';
import 'browser_engine.dart';

void main() => runApp(const CardiaUltimateOS());

class CardiaUltimateOS extends StatelessWidget {
  const CardiaUltimateOS({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF00050A)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const ChatPage(), const GhostBrowserPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.cyanAccent,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Vault Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: "Ghost Web"),
        ],
      ),
    );
  }
}

// صفحة متصفح الشبح
class GhostBrowserPage extends StatefulWidget {
  const GhostBrowserPage({super.key});
  @override
  State<GhostBrowserPage> createState() => _GhostBrowserPageState();
}

class _GhostBrowserPageState extends State<GhostBrowserPage> {
  final GhostBrowser _browser = GhostBrowser();
  final TextEditingController _urlCon = TextEditingController();
  String _pageContent = "Search the web via DNS Tunnel...";
  bool _isLoading = false;

  _search() async {
    setState(() => _isLoading = true);
    final res = await _browser.fetchText(_urlCon.text);
    setState(() {
      _pageContent = res;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GHOST BROWSER", style: TextStyle(fontSize: 14))),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(color: Colors.magentaAccent),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _urlCon,
              decoration: InputDecoration(
                hintText: "Enter URL (e.g. google.com)",
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: SingleChildScrollView(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_pageContent, style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent)),
          ))),
        ],
      ),
    );
  }
}

// (صفحة الدردشة ChatPage تبقى كما هي في الكود السابق)
class ChatPage extends StatelessWidget { const ChatPage({super.key}); @override Widget build(BuildContext context) { return const Center(child: Text("Vault Chat Interface Active")); } }
