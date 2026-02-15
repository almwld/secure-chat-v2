import 'dart:convert';
import 'package:intl/intl.dart';

class EncryptionService {
  String encrypt(String plain) {
    String key = DateFormat('HH').format(DateTime.now()); // مفتاح يتغير كل ساعة
    List<int> pBytes = utf8.encode(plain);
    List<int> kBytes = utf8.encode(key);
    return base64Url.encode(pBytes.map((b) => b ^ kBytes[0]).toList());
  }
}
