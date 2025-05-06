// Path: lib/injection_container.dart
import 'package:bloc_learn/core/db/database_helper.dart';
import 'package:bloc_learn/core/theme/bloc/theme_bloc.dart';
import 'package:bloc_learn/core/theme/theme_preferences.dart';
import 'package:bloc_learn/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:bloc_learn/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:bloc_learn/features/todo/domain/repositories/todo_repository.dart';
import 'package:bloc_learn/features/todo/domain/usecases/add_todo.dart';
import 'package:bloc_learn/features/todo/domain/usecases/delete_todo.dart';
import 'package:bloc_learn/features/todo/domain/usecases/get_todos.dart';
import 'package:bloc_learn/features/todo/domain/usecases/search_completed_todos.dart';
import 'package:bloc_learn/features/todo/domain/usecases/update_todo.dart';
import 'package:bloc_learn/features/todo/presentation/bloc/search_bloc.dart';
import 'package:bloc_learn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  // Core
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  sl.registerLazySingleton<ThemePreferences>(
    () => ThemePreferences(),
  ); // Thêm dòng này

  // Theme
  sl.registerFactory(() => ThemeBloc(themePreferences: sl())); // Thêm dòng này
  sl.registerFactory(
    () => SearchBloc(searchCompletedTodos: sl()),
  ); // Thêm dòng này
  // Features - Todo
  // BLoC
  // Đăng ký là factory vì BLoC thường có state riêng và nên được tạo mới khi cần
  sl.registerFactory(
    () => TodoBloc(
      getTodos: sl(),
      addTodo: sl(),
      updateTodo: sl(),
      deleteTodo: sl(),
    ),
  );

  // Use cases
  // Đăng ký là lazy singleton vì use case không có state và có thể tái sử dụng
  sl.registerLazySingleton(() => GetTodos(sl()));
  sl.registerLazySingleton(() => AddTodo(sl()));
  sl.registerLazySingleton(() => UpdateTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));
  sl.registerLazySingleton(() => SearchCompletedTodos(sl())); // Thêm dòng này

  // Repository
  // Đăng ký interface TodoRepository với implementation là TodoRepositoryImpl
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  // Đăng ký interface TodoLocalDataSource với implementation là TodoLocalDataSourceImpl
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(databaseHelper: sl()),
  );

  // External (ví dụ: DatabaseHelper đã đăng ký ở trên trong Core)
}
