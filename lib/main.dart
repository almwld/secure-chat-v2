import 'package:flutter/material.dart';

void main() {
  runApp(const SecureChatApp());
}

class SecureChatApp extends StatelessWidget {
  const SecureChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apscroworld',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00C853),
        scaffoldBackgroundColor: const Color(0xFF050505),
      ),
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

  final List<Map<String, String>> chats = [
    {"name": "Admin Pro", "msg": "نظام التشفير يعمل بنجاح..."},
    {"name": "Secure Node 01", "msg": "تم استقبال البيانات المشفرة."},
    {"name": "Root Master", "msg": "تحذير: محاولة دخول غير مصرح بها تم صدها."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('APSCROWORLD', style: TextStyle(color: Color(0xFF00C853), letterSpacing: 2)),
        actions: [IconButton(icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF00C853)), onPressed: () {})],
      ),
      body: _currentIndex == 0 ? _buildChatList() : _buildCallLogs(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF00C853),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "دردشة"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "مكالمات"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "إعدادات"),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF00C853),
            child: Text(chats[index]['name']![0], style: const TextStyle(color: Colors.black)),
          ),
          title: Text(chats[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chats[index]['msg']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: const Text("12:00", style: TextStyle(color: Colors.grey, fontSize: 10)),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildCallLogs() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security, size: 80, color: Color(0xFF00C853)),
          SizedBox(height: 10),
          Text("سجل المكالمات مشفر بالكامل", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
