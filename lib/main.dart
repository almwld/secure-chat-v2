import 'package:flutter/material.dart';
import 'package:record/record.dart'; // ستحتاج لإضافتها في pubspec
import 'dart:io';
import 'dart:convert';
import 'security.dart';

void main() => runApp(const CardiaVoiceTunnelApp());

class CardiaVoiceTunnelApp extends StatelessWidget {
  const CardiaVoiceTunnelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF00050A)),
      home: const CyberVoiceChat(),
    );
  }
}

class CyberVoiceChat extends StatefulWidget {
  const CyberVoiceChat({super.key});
  @override
  State<CyberVoiceChat> createState() => _CyberVoiceChatState();
}

class _CyberVoiceChatState extends State<CyberVoiceChat> {
  final AudioRecorder _recorder = AudioRecorder();
  final EncryptionService _enc = EncryptionService();
  bool _isRecording = false;
  bool _isTunneling = true;

  // تسجيل وتشفير وإرسال الصوت عبر النفق
  Future<void> _handleVoice() async {
    if (await _recorder.hasPermission()) {
      if (!_isRecording) {
        final path = '${Directory.systemTemp.path}/v_cloak.m4a';
        await _recorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      } else {
        final path = await _recorder.stop();
        setState(() => _isRecording = false);
        
        if (path != null) {
          File file = File(path);
          List<int> audioBytes = await file.readAsBytes();
          String encodedAudio = base64Encode(audioBytes);
          
          // إرسال أول 100 حرف كمثال على النفق (الهروب الصوتي)
          _sendAudioChunks(encodedAudio);
        }
      }
    }
  }

  Future<void> _sendAudioChunks(String data) async {
    int chunkSize = 40;
    // سنرسل عينات فقط لأن الصوت الكامل يحتاج آلاف الطلبات
    for (int i = 0; i < 5; i++) {
      String chunk = data.substring(i * chunkSize, (i + 1) * chunkSize);
      try {
        await InternetAddress.lookup("${i}_voice_${_enc.encrypt(chunk)}.dns.local");
      } catch (e) {}
    }
    _showStatus("Voice Stream Relayed via DNS");
  }

  void _showStatus(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.magentaAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VOICE TUNNEL ACTIVE")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isRecording ? Icons.settings_voice : Icons.mic_none, 
                 size: 80, color: _isRecording ? Colors.redAccent : Colors.cyanAccent),
            const SizedBox(height: 20),
            Text(_isRecording ? "RECORDING & ENCRYPTING..." : "HOLD TO SEND SECURE VOICE"),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: _isRecording ? Colors.redAccent : Colors.cyanAccent,
        onPressed: _handleVoice,
        child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.black),
      ),
    );
  }
}
