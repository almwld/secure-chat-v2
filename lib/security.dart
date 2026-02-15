import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class EncryptionService {
  // توليد مفتاح يتغير كل ساعة بناءً على التاريخ والوقت
  String _generateDynamicKey() {
    String timeSeed = DateFormat('yyyy-MM-dd-HH').format(DateTime.now());
    var bytes = utf8.encode(timeSeed + "CARDIA_SALT_2026"); 
    return sha256.convert(bytes).toString().substring(0, 32);
  }

  String encrypt(String plainText) {
    String key = _generateDynamicKey();
    // تشفير XOR بسيط مع المفتاح الديناميكي لضمان السرعة عبر النفق
    List<int> plainBytes = utf8.encode(plainText);
    List<int> keyBytes = utf8.encode(key);
    List<int> encrypted = [];
    
    for (int i = 0; i < plainBytes.length; i++) {
      encrypted.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return base64Url.encode(encrypted);
  }

  String decrypt(String encryptedText) {
    try {
      String key = _generateDynamicKey();
      List<int> encryptedBytes = base64Url.decode(encryptedText);
      List<int> keyBytes = utf8.encode(key);
      List<int> decrypted = [];
      
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      return utf8.decode(decrypted);
    } catch (e) {
      return "[!] Decryption Error: Key Mismatch";
    }
  }
}
