import 'package:education/models/selected_course_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedCourseStorage {
  static const String _prefsKey = 'selectedCourseData';

  static Future<SelectedCourseData?> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return SelectedCourseData.fromRawJson(raw);
  }

  static Future<void> save(SelectedCourseData data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, data.toRawJson());
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
