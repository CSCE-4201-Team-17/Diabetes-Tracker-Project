import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //Auth token
  static String? get authToken => _prefs.getString('auth_token');
  static Future<void> setAuthToken(String token) => _prefs.setString('auth_token', token);
  static Future<void> removeAuthToken() => _prefs.remove('auth_token');

  //User data
  static String? get userId => _prefs.getString('user_id');
  static Future<void> setUserId(String id) => _prefs.setString('user_id', id);
  static Future<void> removeUserId() => _prefs.remove('user_id');

  //User preferences
  static bool get enableReminders => _prefs.getBool('enable_reminders') ?? true;
  static Future<void> setEnableReminders(bool value) => _prefs.setBool('enable_reminders', value);

  static bool get darkMode => _prefs.getBool('dark_mode') ?? false;
  static Future<void> setDarkMode(bool value) => _prefs.setBool('dark_mode', value);

  //Clear all data (logout)
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}