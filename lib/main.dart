import 'package:flutter/material.dart';

void main() {
  runApp(const ApscroworldApp());
}

class ApscroworldApp extends StatelessWidget {
  const ApscroworldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apscroworld',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00C853), // اللون الزمردي
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00C853), width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield, size: 100, color: Color(0xFF00C853)),
              const SizedBox(height: 20),
              const Text(
                'APSCROWORLD',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C853),
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'SECURE COMMUNICATION',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                child: const Text('دخول النظام الآمن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
