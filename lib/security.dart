import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  // مفتاح تشفير ثابت (يجب تغييره في الإنتاج لزيادة الأمان)
  final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final _iv = encrypt.IV.fromLength(16);

  String encrypt(String text) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      return "[Error Decrypting]";
    }
  }
}
