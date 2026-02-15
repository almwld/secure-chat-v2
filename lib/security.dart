import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final Key _key = Key.fromUtf8('c4rdia_secure_offline_key_32bit!');
  final IV _iv = IV.fromLength(16);

  String encrypt(String text) {
    final encrypter = Encrypter(AES(_key));
    return encrypter.encrypt(text, iv: _iv).base64;
  }

  String decrypt(String encryptedText) {
    try {
      final encrypter = Encrypter(AES(_key));
      return encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      return "[Data Locked]";
    }
  }
}
