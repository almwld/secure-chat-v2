import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalVault {
  static const String _key = "cardia_permanent_vault";

  // حفظ الرسالة في الخزنة
  Future<void> saveMessage(Map<String, dynamic> msg) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    history.add(jsonEncode(msg));
    await prefs.setStringList(_key, history);
  }

  // استعادة الأرشيف بالكامل
  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}
