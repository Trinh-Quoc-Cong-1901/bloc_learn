import 'package:shared_preferences/shared_preferences.dart';
import 'theme_data.dart';

class ThemePreferences {
  static const _themeKey = 'app_theme';

  Future<void> saveTheme(AppThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.toString());
  }

  Future<AppThemeMode> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString =
        prefs.getString(_themeKey) ?? AppThemeMode.system.toString();
    return AppThemeMode.values.firstWhere(
      (e) => e.toString() == themeString,
      orElse: () => AppThemeMode.system,
    );
  }
}
