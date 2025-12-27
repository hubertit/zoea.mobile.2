import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';

class TokenStorageService {
  static TokenStorageService? _instance;
  SharedPreferences? _prefs;

  TokenStorageService._();

  static Future<TokenStorageService> getInstance() async {
    _instance ??= TokenStorageService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs?.setString(AppConfig.authTokenKey, accessToken);
    await _prefs?.setString('${AppConfig.authTokenKey}_refresh', refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _prefs?.getString(AppConfig.authTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _prefs?.getString('${AppConfig.authTokenKey}_refresh');
  }

  Future<void> clearTokens() async {
    await _prefs?.remove(AppConfig.authTokenKey);
    await _prefs?.remove('${AppConfig.authTokenKey}_refresh');
  }

  Future<void> saveUserData(User user) async {
    // Store user data as JSON string
    final userJson = jsonEncode(user.toJson());
    await _prefs?.setString(AppConfig.userDataKey, userJson);
    await _prefs?.setBool(AppConfig.isLoggedInKey, true);
  }

  Future<User?> getUserData() async {
    final userJsonString = _prefs?.getString(AppConfig.userDataKey);
    if (userJsonString == null) return null;
    
    try {
      final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      return User.fromJson(userJson);
    } catch (e) {
      // If parsing fails, clear corrupted data
      await clearUserData();
      return null;
    }
  }

  Future<void> clearUserData() async {
    await _prefs?.remove(AppConfig.userDataKey);
    await _prefs?.setBool(AppConfig.isLoggedInKey, false);
  }

  Future<bool> isLoggedIn() async {
    return _prefs?.getBool(AppConfig.isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(AppConfig.isLoggedInKey, value);
  }
}

