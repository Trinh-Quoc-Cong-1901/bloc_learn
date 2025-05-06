import 'package:bloc_learn/core/theme/bloc/theme_bloc.dart';
import 'package:bloc_learn/core/theme/theme_data.dart';
import 'package:bloc_learn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:bloc_learn/features/todo/presentation/pages/todo_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeBloc>()..add(LoadThemeEvent())),
        BlocProvider(create: (_) => sl<TodoBloc>()..add(LoadTodosEvent())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Todo App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _mapAppThemeMode(themeState.themeMode),
            home: const TodoListPage(),
          );
        },
      ),
    );
  }

  ThemeMode _mapAppThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
