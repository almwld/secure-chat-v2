import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'security.dart';

void main() => runApp(const CardiaTurboApp());

class CardiaTurboApp extends StatelessWidget {
  const CardiaTurboApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF00050A)),
      home: const TurboChat(),
    );
  }
}

class TurboChat extends StatefulWidget {
  const TurboChat({super.key});
  @override
  State<TurboChat> createState() => _TurboChatState();
}

class _TurboChatState extends State<TurboChat> {
  final EncryptionService _enc = EncryptionService();
  String _status = "READY";
  double _speed = 0.0;

  // محرك الإرسال المتوازي (التوربو)
  Future<void> _sendTurbo(String largeData) async {
    int chunkSize = 45;
    List<String> chunks = [];
    
    // 1. تقطيع البيانات
    for (var i = 0; i < largeData.length; i += chunkSize) {
      chunks.add(largeData.substring(i, i + chunkSize > largeData.length ? largeData.length : i + chunkSize));
    }

    setState(() => _status = "BURSTING...");

    // 2. إرسال 10 طرود في آن واحد (Parallel Burst)
    for (var i = 0; i < chunks.length; i += 10) {
      int end = (i + 10 < chunks.length) ? i + 10 : chunks.length;
      List<Future> burst = [];
      
      for (var j = i; j < end; j++) {
        String packet = "${j}_${_enc.encrypt(chunks[j])}.t.local";
        burst.add(InternetAddress.lookup(packet));
      }

      // إضافة طرد وهمي للتمويه 
      burst.add(InternetAddress.lookup("google.com")); 
      burst.add(InternetAddress.lookup("connectivitycheck.gstatic.com")); 
      // تأخير عشوائي بسيط لكسر النمط 
      await Future.delayed(Duration(milliseconds: (new DateTime.now().millisecond % 100)));
      await Future.wait(burst).catchError((e) => []); // إرسال الدفعة
      
      setState(() {
        _speed = (i / chunks.length);
      });
    }

    setState(() {
      _status = "FINISHED";
      _speed = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TURBO TUNNEL: $_status"), backgroundColor: Colors.black),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_speed > 0) CircularProgressIndicator(value: _speed, color: Colors.cyanAccent, strokeWidth: 10),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.bolt),
              label: const Text("FAST SEND (10x Speed)"),
              onPressed: () => _sendTurbo("TEST_DATA_STREAM_MAX_SPEED_V2_2026"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
