import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(0xFF00080F),
  ));
  runApp(const CardiaApp());
}

class CardiaApp extends StatelessWidget {
  const CardiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cardia Ultimate',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF00080F),
        primaryColor: Colors.cyanAccent,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.deepPurpleAccent,
          surface: Color(0xFF111625),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}

// --- 1. Login Screen ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  
  void _checkPin(String value) {
    if (value == "1234") {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (value.length == 4) {
      _pinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ACCESS DENIED"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            const Text("CARDIA OS", style: TextStyle(letterSpacing: 5, fontSize: 20)),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 10),
                decoration: InputDecoration(
                  hintText: "Enter PIN",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  filled: true,
                  fillColor: Colors.white10,
                ),
                onChanged: _checkPin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. Home Screen ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _users = ["Ghost Node", "Shadow Unit", "Cyber Base", "Alpha Team"];
  List<String> _filteredUsers = [];
  bool _isSearching = false;

  @override
  void initState() {
    _filteredUsers = _users;
    super.initState();
  }

  void _runSearch(String keyword) {
    setState(() {
      _filteredUsers = _users.where((user) => user.toLowerCase().contains(keyword.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: "Search Frequency...", border: InputBorder.none),
              onChanged: _runSearch,
            )
          : const Text("ACTIVE NODES"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _filteredUsers = _users;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.deepPurpleAccent, child: Icon(Icons.person_outline)),
            title: Text(_filteredUsers[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Encrypted connection established...", style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: const Icon(Icons.signal_cellular_alt, color: Colors.greenAccent, size: 16),
            onTap: () => Navigator.pushNamed(context, '/chat', arguments: _filteredUsers[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {},
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF111625),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Commander"),
            accountEmail: Text("ID: 99-XA-2026"),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.cyanAccent, child: Icon(Icons.security)),
            decoration: BoxDecoration(color: Color(0xFF00080F)),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.cyanAccent),
            title: const Text("System Settings"),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text("Terminate Session"),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}

// --- 3. Chat Screen ---
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    if (_msgController.text.isEmpty) return;
    setState(() {
      _messages.insert(0, {
        "text": _msgController.text,
        "isMe": true,
        "time": DateFormat('HH:mm').format(DateTime.now())
      });
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.insert(0, {
            "text": "Data packet received via DNS Tunnel.",
            "isMe": false,
            "time": DateFormat('HH:mm').format(DateTime.now())
          });
        });
      }
    });
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final String userName = ModalRoute.of(context)!.settings.arguments as String? ?? "Unknown Node";
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const CircleAvatar(radius: 15, backgroundColor: Colors.cyanAccent, child: Icon(Icons.lock, size: 12)),
          const SizedBox(width: 10),
          Text(userName, style: const TextStyle(fontSize: 16)),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg['isMe'] ? Colors.deepPurpleAccent.withOpacity(0.2) : Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: msg['isMe'] ? Colors.deepPurpleAccent : Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg['text'], style: const TextStyle(fontSize: 16)),
                        Text(msg['time'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF111625),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: "Secure Message...",
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.cyanAccent), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 4. Settings Screen ---
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _turboMode = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SYSTEM CONFIG")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            activeColor: Colors.deepPurpleAccent,
            title: const Text("Turbo DNS Burst"),
            value: _turboMode,
            onChanged: (v) => setState(() => _turboMode = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text("DESTROY VAULT"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.2), foregroundColor: Colors.red),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

// --- 5. Notifications Screen ---
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SECURITY ALERTS")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text("Port Scanned"),
            subtitle: Text("10:00 AM - Attempt blocked"),
          ),
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Tunnel Established"),
            subtitle: Text("09:45 AM - Connected via 8.8.8.8"),
          ),
        ],
      ),
    );
  }
}
