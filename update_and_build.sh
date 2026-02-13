#!/bin/bash

# التأكد من وجود مجلد lib
mkdir -p lib

# كتابة الكود داخل main.dart
cat << 'EOT' > lib/main.dart
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData.dark(),
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    ));

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Secure Chat Pro')),
      body: Column(
        children: [
          Expanded(child: Center(child: Icon(Icons.lock_outline, size: 100, color: Colors.blue))),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "اكتب رسالة مشفرة...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                suffixIcon: Icon(Icons.send),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
EOT

# إضافة التغييرات والرفع
git add .
git commit -m "Fix directory structure and update UI"
git push origin main

echo "------------------------------------------------"
echo "✅ تم الإصلاح والرفع بنجاح!"
echo "🚀 راقب موقع Codemagic الآن، البناء سيبدأ آلياً."
echo "------------------------------------------------"
