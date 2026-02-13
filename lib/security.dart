import 'package:encrypt/encrypt.dart' as crypto;

class EncryptionService {
  // استخدام late لضمان التهيئة الصحيحة
  final crypto.Key _key = crypto.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final crypto.IV _iv = crypto.IV.fromLength(16);

  String encrypt(String text) {
    final encrypter = crypto.Encrypter(crypto.AES(_key));
    final encrypted = encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    try {
      final encrypter = crypto.Encrypter(crypto.AES(_key));
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      return "[Error Decrypting]";
    }
  }
}
