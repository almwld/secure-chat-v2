import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final Key _key = Key.fromUtf8('c4rdia_secure_cloak_key_32bit!!!');
  final IV _iv = IV.fromLength(16);

  // قائمة جمل التمويه
  final List<String> _covers = [
    "الجو غائم اليوم بشكل غريب",
    "تأكد من إغلاق النوافذ جيداً",
    "المباراة كانت ممتعة جداً أمس",
    "سأتصل بك عندما أصل للمنزل",
    "هل تذكر أين وضعنا الكتاب؟",
    "قائمة الطلبات: حليب، خبز، وماء"
  ];

  String encrypt(String text) {
    if (text.isEmpty) return "";
    final encrypter = Encrypter(AES(_key));
    String secret = encrypter.encrypt(text, iv: _iv).base64;
    
    // اختيار جملة عشوائية للتمويه وإضافة السر بعدها بمسافات خفية
    String cover = (_covers..shuffle()).first;
    return "$cover |$secret"; // السر يوضع بعد علامة الفاصلة
  }

  String decrypt(String fullText) {
    try {
      if (!fullText.contains('|')) return fullText;
      String secret = fullText.split('|')[1].trim();
      final encrypter = Encrypter(AES(_key));
      return encrypter.decrypt64(secret, iv: _iv);
    } catch (e) {
      return fullText.split('|')[0]; // إذا فشل فك التشفير، يظهر النص العادي فقط
    }
  }

  String getCoverOnly(String fullText) {
    return fullText.contains('|') ? fullText.split('|')[0] : fullText;
  }
}
