import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../theme_data.dart';
import '../theme_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemePreferences themePreferences;

  ThemeBloc({required this.themePreferences})
    : super(const ThemeState(themeMode: AppThemeMode.system)) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final themeMode = await themePreferences.getTheme();
    emit(ThemeState(themeMode: themeMode));
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newThemeMode = _getNextThemeMode(state.themeMode);
    await themePreferences.saveTheme(newThemeMode);
    emit(ThemeState(themeMode: newThemeMode));
  }

  AppThemeMode _getNextThemeMode(AppThemeMode current) {
    switch (current) {
      case AppThemeMode.light:
        return AppThemeMode.dark;
      case AppThemeMode.dark:
        return AppThemeMode.system;
      case AppThemeMode.system:
        return AppThemeMode.light;
    }
  }
}
