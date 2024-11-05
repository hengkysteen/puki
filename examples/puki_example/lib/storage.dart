import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String _userKey = 'user';

  // Fungsi untuk menyimpan data pengguna ke SharedPreferences
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(userData);
    await prefs.setString(_userKey, userJson);
  }

  // Fungsi untuk mengambil data pengguna dari SharedPreferences
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Fungsi untuk menghapus data pengguna dari SharedPreferences
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
