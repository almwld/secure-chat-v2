import 'package:encrypt/encrypt.dart' as crypto;
import 'dart:typed_data';

class EncryptionService {
  final crypto.Key _key = crypto.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final crypto.IV _iv = crypto.IV.fromLength(16);

  // تشفير النصوص
  String encrypt(String text) {
    final encrypter = crypto.Encrypter(crypto.AES(_key));
    return encrypter.encrypt(text, iv: _iv).base64;
  }

  String decrypt(String encryptedText) {
    try {
      final encrypter = crypto.Encrypter(crypto.AES(_key));
      return encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      return "[Error]";
    }
  }

  // تشفير الملفات والصور (Bytes)
  Uint8List encryptBytes(Uint8List data) {
    final encrypter = crypto.Encrypter(crypto.AES(_key));
    final encrypted = encrypter.encryptBytes(data, iv: _iv);
    return encrypted.bytes;
  }

  Uint8List decryptBytes(Uint8List encryptedData) {
    final encrypter = crypto.Encrypter(crypto.AES(_key));
    final decrypted = encrypter.decryptBytes(crypto.Encrypted(encryptedData), iv: _iv);
    return Uint8List.fromList(decrypted);
  }
}
