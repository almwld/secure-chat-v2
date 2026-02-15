import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // ستحتاج لإضافة file_picker في pubspec
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'security.dart';

void main() => runApp(const CardiaFileTunnelApp());

class CardiaFileTunnelApp extends StatelessWidget {
  const CardiaFileTunnelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF00050A)),
      home: const CyberChat(),
    );
  }
}

class CyberChat extends StatefulWidget {
  const CyberChat({super.key});
  @override
  State<CyberChat> createState() => _CyberChatState();
}

class _CyberChatState extends State<CyberChat> {
  final EncryptionService _enc = EncryptionService();
  bool _isTunneling = false;
  double _uploadProgress = 0.0;

  // محرك نقل الملفات عبر النفق
  Future<void> _sendFileViaTunnel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      File file = File(result.files.single.path!);
      List<int> bytes = await file.readAsBytes();
      String base64File = base64Encode(bytes);
      
      // تقطيع الملف إلى أجزاء صغيرة (مثلاً 50 حرف لكل طلب DNS)
      int chunkSize = 50;
      int totalChunks = (base64File.length / chunkSize).ceil();

      for (int i = 0; i < totalChunks; i++) {
        int end = (i + 1) * chunkSize;
        if (end > base64File.length) end = base64File.length;
        
        String chunk = base64File.substring(i * chunkSize, end);
        String secretChunk = _enc.encrypt(chunk);

        // إرسال القطعة عبر DNS
        try {
          await InternetAddress.lookup("${i}_${totalChunks}_$secretChunk.data.local");
        } catch (e) { /* تهريب ناجح */ }

        setState(() {
          _uploadProgress = (i + 1) / totalChunks;
        });
      }
      
      setState(() => _uploadProgress = 0.0);
      _showCompleteDialog();
    }
  }

  void _showCompleteDialog() {
    showDialog(context: context, builder: (c) => const AlertDialog(content: Text("File Fragmented & Relayed via Tunnel")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FILE TUNNEL v1.0", style: TextStyle(letterSpacing: 2)),
        actions: [
          Switch(value: _isTunneling, onChanged: (v) => setState(() => _isTunneling = v))
        ],
      ),
      body: Column(
        children: [
          if (_uploadProgress > 0) LinearProgressIndicator(value: _uploadProgress, color: Colors.magentaAccent),
          const Expanded(child: Center(child: Text("Ready for Secure Transmission"))),
          _buildControlBar(),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.cyanAccent),
            onPressed: _isTunneling ? _sendFileViaTunnel : null,
          ),
          const Text("Select File to Fragment"),
          const Icon(Icons.mic, color: Colors.white24), // سيتم تفعيلها في التحديث الصوتي
        ],
      ),
    );
  }
}
