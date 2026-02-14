import 'package:encrypt/encrypt.dart' as crypto;

class EncryptionService {
  // مفتاح تشفير 32 بت - عسكري القوة
  final crypto.Key _key = crypto.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final crypto.IV _iv = crypto.IV.fromLength(16);

  String encrypt(String text) {
    if (text.isEmpty) return "";
    final encrypter = crypto.Encrypter(crypto.AES(_key));
    return encrypter.encrypt(text, iv: _iv).base64;
  }

  String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return "";
    try {
      final encrypter = crypto.Encrypter(crypto.AES(_key));
      return encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      return "[رسالة مشفرة]";
    }
  }
}
