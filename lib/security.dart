import 'package:encrypt/encrypt.dart' as crypto;

class EncryptionService {
  // مفتاح التشفير الأساسي (يجب أن يكون سرياً تماماً)
  final crypto.Key _key = crypto.Key.fromUtf8('c4rdia_secure_key_32_chars_long!');
  final crypto.IV _iv = crypto.IV.fromLength(16);

  String encrypt(String text) {
    if (text.isEmpty) return "";
    final encrypter = crypto.Encrypter(crypto.AES(_key, mode: crypto.AESMode.cbc));
    return encrypter.encrypt(text, iv: _iv).base64;
  }

  String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return "";
    try {
      final encrypter = crypto.Encrypter(crypto.AES(_key, mode: crypto.AESMode.cbc));
      return encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      return "[Encrypted Data]";
    }
  }
}
