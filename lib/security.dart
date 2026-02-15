import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // المفتاح يجب أن يكون 32 حرفاً بالضبط لـ AES-256
  final Key _key = Key.fromUtf8('c4rdia_secure_key_32_chars_long!');
  final IV _iv = IV.fromLength(16);

  String encrypt(String text) {
    if (text.isEmpty) return "";
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    return encrypter.encrypt(text, iv: _iv).base64;
  }

  String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return "";
    try {
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      return encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      return "[Encrypted Data]";
    }
  }
}
