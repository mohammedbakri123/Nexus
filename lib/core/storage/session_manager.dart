import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';
  static const _keyEmail = 'email';
  static const _keyLevel = 'level';

  /// SAVE SESSION
  static Future<void> saveUser({
    required int userId,
    required String username,
    required String email,
    required int level,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setInt(_keyLevel, level);
  }

  /// CHECK LOGIN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  /// GET USER ID (for favorites)
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// GET USERNAME
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<int?> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLevel);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static const _keyBio = 'user_bio';

  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  static Future<void> setBio(String bio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBio, bio);
  }

  static Future<String?> getBio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBio);
  }
}
