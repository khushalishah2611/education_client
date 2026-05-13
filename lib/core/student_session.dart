import 'package:shared_preferences/shared_preferences.dart';

class StudentSession {
  const StudentSession._();

  static const String _loggedInKey = 'isLoggedIn';
  static const String _studentUserIdKey = 'studentUserId';
  static const String _authTokenKey = 'authToken';
  static const String _loginCountryKey = 'loginCountry';
  static const String _loginDialCodeKey = 'loginDialCode';

  static Future<void> saveLogin({
    required String studentUserId,
    required String loginCountry,
    required String loginDialCode,
    required String authToken,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_studentUserIdKey, studentUserId.trim());
    if (loginCountry.trim().isNotEmpty) {
      await prefs.setString(_loginCountryKey, loginCountry.trim());
    }
    if (loginDialCode.trim().isNotEmpty) {
      await prefs.setString(_loginDialCodeKey, loginDialCode.trim());
    }
    if (authToken.trim().isNotEmpty) {
      await prefs.setString(_authTokenKey, authToken.trim());
    }
  }

  static Future<String> currentStudentUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_studentUserIdKey)?.trim() ?? '';
  }
}
