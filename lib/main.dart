import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() => runApp(ApscroworldApp());

class ApscroworldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apscroworld',
      // --- الثيم المحدث ليطابق اللوجو (الدرع والتقنية) ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00C853), // أخضر زمردي نيون
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C853),
          brightness: Brightness.dark,
          primary: const Color(0xFF00C853),
          secondary: const Color(0xFFFFD700), // ذهبي (تناسقاً مع الدرع)
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Color(0xFF00C853), fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("APSCROWORLD"),
        actions: [
          IconButton(icon: const Icon(Icons.shield_outlined, color: Color(0xFFFFD700)), onPressed: () {}), // أيقونة الدرع الذهبي
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildChatList(),
          const Center(child: Text("المستجدات الآمنة")),
          const Center(child: Text("مجتمعات الدرع")),
          const Center(child: Text("المكالمات المشفرة")),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: const Color(0xFF00C853).withOpacity(0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF00C853)), label: "الدردشات"),
          NavigationDestination(icon: Icon(Icons.update), label: "المستجدات"),
          NavigationDestination(icon: Icon(Icons.security), label: "الدرع"),
          NavigationDestination(icon: Icon(Icons.call_outlined), label: "المكالمات"),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView(
      children: [
        _chatItem("نظام Apscroworld", "تم تفعيل بروتوكول الدرع بنجاح.", "الآن", true),
        _chatItem("المطور نانو", "اللوجو الجديد مدمج في الثيم.", "3:30 م", false),
      ],
    );
  }

  Widget _chatItem(String name, String msg, String time, bool active) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: active ? const Color(0xFFFFD700) : Colors.transparent)),
        child: const CircleAvatar(backgroundColor: Color(0xFF1A1A1A), child: Icon(Icons.person, color: Colors.white54)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(msg, maxLines: 1),
      trailing: Text(time, style: TextStyle(color: active ? const Color(0xFF00C853) : Colors.grey)),
    );
  }
}
