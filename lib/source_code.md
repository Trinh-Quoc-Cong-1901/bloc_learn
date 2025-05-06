# Source Code Summary

## Directory Structure
```
./
  main.dart
  source_code.md
  injection_container.dart
  core/
    theme/
      theme_preferences.dart
      theme_data.dart
      bloc/
        theme_bloc.dart
        theme_event.dart
        theme_state.dart
    db/
      database_helper.dart
    error/
      failures.dart
    usecases/
      usecase.dart
  features/
    todo/
      data/
        datasources/
          todo_local_data_source.dart
        repositories/
          todo_repository_impl.dart
        models/
          todo_model.dart
      domain/
        repositories/
          todo_repository.dart
        usecases/
          add_todo.dart
          update_todo.dart
          get_todos.dart
          delete_todo.dart
        entities/
          todo_entity.dart
      presentation/
        pages/
          todo_list_page.dart
        widgets/
        bloc/
          todo_bloc.dart
          todo_state.dart
          todo_event.dart
```


## File Contents


### main.dart

```dart
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

```

---


### injection_container.dart

```dart
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
import 'package:bloc_learn/features/todo/domain/usecases/update_todo.dart';
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

```

---


### core/theme/theme_preferences.dart

```dart
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

```

---


### core/theme/theme_data.dart

```dart
import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}

```

---


### core/theme/bloc/theme_bloc.dart

```dart
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

```

---


### core/theme/bloc/theme_event.dart

```dart
part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {}

class ChangeThemeEvent extends ThemeEvent {}

```

---


### core/theme/bloc/theme_state.dart

```dart
part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final AppThemeMode themeMode;

  const ThemeState({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

```

---


### core/db/database_helper.dart

```dart
// Path: lib/core/db/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "TodoApp.db";
  static const _databaseVersion = 1;

  static const tableTodo = 'todos';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnIsCompleted = 'isCompleted';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create it if it doesn't exist
  _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTodo (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnIsCompleted INTEGER NOT NULL DEFAULT 0
      )
      ''');
  }
}

```

---


### core/error/failures.dart

```dart
// Path: lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

```

---


### core/usecases/usecase.dart

```dart
// Path: lib/core/usecases/usecase.dart
import 'package:equatable/equatable.dart';

// Lưu ý: 'package:dartz/dartz.dart' thường được dùng ở đây cho Either.
// Để giữ đơn giản, tạm thời chúng ta sẽ không dùng Either.
// Nếu bạn muốn xử lý lỗi mạnh mẽ hơn, hãy cân nhắc thêm package dartz.

// For UseCases that don't take parameters
abstract class UseCase<Type, NoParams> {
  Future<Type> call(
    NoParams params,
  ); // Hoặc Future<Either<Failure, Type>> call(NoParams params);
}

// For UseCases that take parameters
abstract class UseCaseWithParams<Type, Params> {
  Future<Type> call(
    Params params,
  ); // Hoặc Future<Either<Failure, Type>> call(Params params);
}

// A simple NoParams class, as we don't have dartz's Unit
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

```

---


### features/todo/data/datasources/todo_local_data_source.dart

```dart
// Path: lib/features/todo/data/datasources/todo_local_data_source.dart
import 'package:bloc_learn/core/db/database_helper.dart';
import 'package:bloc_learn/core/error/failures.dart';
import 'package:bloc_learn/features/todo/data/models/todo_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> addTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final DatabaseHelper databaseHelper;

  TodoLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTodo,
        orderBy: '${DatabaseHelper.columnId} DESC',
      );
      return List.generate(maps.length, (i) {
        return TodoModel.fromMap(maps[i]);
      });
    } catch (e) {
      // Thay vì throw Failure, nên throw một Exception cụ thể
      // Ví dụ: throw DatabaseException(message: 'Failed to get todos: ${e.toString()}');
      // Failures sẽ được map ở RepositoryImpl
      throw DatabaseFailure(message: 'Failed to get todos: ${e.toString()}');
    }
  }

  @override
  Future<TodoModel> addTodo(TodoModel todo) async {
    try {
      final db = await databaseHelper.database;
      final id = await db.insert(
        DatabaseHelper.tableTodo,
        todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Trả về TodoModel với id đã được gán bởi database
      return todo.copyWith(id: id);
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to add todo: ${e.toString()}');
    }
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        DatabaseHelper.tableTodo,
        todo.toMap(),
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [todo.id],
      );
      return todo; // Trả về todo đã được cập nhật
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to update todo: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        DatabaseHelper.tableTodo,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to delete todo: ${e.toString()}');
    }
  }
}

```

---


### features/todo/data/repositories/todo_repository_impl.dart

```dart
// Path: lib/features/todo/data/repositories/todo_repository_impl.dart

// Nếu dùng dartz: import 'package:dartz/dartz.dart';

import 'package:bloc_learn/core/error/failures.dart';
import 'package:bloc_learn/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:bloc_learn/features/todo/data/models/todo_model.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';
import 'package:bloc_learn/features/todo/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  // Có thể thêm NetworkInfo nếu cần kiểm tra kết nối mạng cho remoteDataSource

  TodoRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TodoEntity>> getTodos() async {
    // Nếu dùng dartz: Future<Either<Failure, List<TodoEntity>>> getTodos() async {
    try {
      final todoModels = await localDataSource.getTodos();
      // Chuyển đổi List<TodoModel> sang List<TodoEntity>
      // Ở đây TodoModel đã là TodoEntity nên không cần chuyển đổi tường minh,
      // nhưng nếu có sự khác biệt thì cần map lại.
      return todoModels; // return Right(todoModels);
    } on DatabaseFailure catch (e) {
      // return Left(DatabaseFailure(message: e.message));
      rethrow; // Hoặc throw e nếu đã là Failure
    } catch (e) {
      // return Left(ServerFailure(message: 'An unexpected error occurred: ${e.toString()}'));
      throw ServerFailure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<TodoEntity> addTodo(TodoEntity todo) async {
    // Nếu dùng dartz: Future<Either<Failure, TodoEntity>> addTodo(TodoEntity todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final addedTodoModel = await localDataSource.addTodo(todoModel);
      return addedTodoModel; // return Right(addedTodoModel);
    } on DatabaseFailure catch (e) {
      // return Left(DatabaseFailure(message: e.message));
      rethrow;
    } catch (e) {
      // return Left(ServerFailure(message: 'Failed to add todo: ${e.toString()}'));
      throw ServerFailure(message: 'Failed to add todo: ${e.toString()}');
    }
  }

  @override
  Future<TodoEntity> updateTodo(TodoEntity todo) async {
    // Nếu dùng dartz: Future<Either<Failure, TodoEntity>> updateTodo(TodoEntity todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final updatedTodoModel = await localDataSource.updateTodo(todoModel);
      return updatedTodoModel; // return Right(updatedTodoModel);
    } on DatabaseFailure catch (e) {
      // return Left(DatabaseFailure(message: e.message));
      rethrow;
    } catch (e) {
      // return Left(ServerFailure(message: 'Failed to update todo: ${e.toString()}'));
      throw ServerFailure(message: 'Failed to update todo: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    // Nếu dùng dartz: Future<Either<Failure, void>> deleteTodo(int id) async {
    try {
      await localDataSource.deleteTodo(id);
      // return const Right(null); // null ở đây tương đương void
    } on DatabaseFailure catch (e) {
      // return Left(DatabaseFailure(message: e.message));
      rethrow;
    } catch (e) {
      // return Left(ServerFailure(message: 'Failed to delete todo: ${e.toString()}'));
      throw ServerFailure(message: 'Failed to delete todo: ${e.toString()}');
    }
  }
}

```

---


### features/todo/data/models/todo_model.dart

```dart
import 'package:bloc_learn/core/db/database_helper.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    super.id, // id có thể null khi tạo mới, db sẽ tự gán
    required super.title,
    required super.isCompleted,
  });

  // Factory constructor để tạo TodoModel từ TodoEntity
  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
    );
  }

  // Chuyển đổi từ Map (đọc từ database) sang TodoModel
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map[DatabaseHelper.columnId] as int?,
      title: map[DatabaseHelper.columnTitle] as String,
      isCompleted:
          (map[DatabaseHelper.columnIsCompleted] as int) ==
          1, // SQLite lưu boolean là 0 hoặc 1
    );
  }

  // Chuyển đổi TodoModel sang Map (để ghi vào database)
  Map<String, dynamic> toMap() {
    return {
      // DatabaseHelper.columnId: id, // Không cần id khi insert vì nó tự tăng
      DatabaseHelper.columnTitle: title,
      DatabaseHelper.columnIsCompleted: isCompleted ? 1 : 0,
    };
  }

  // Tạo một bản copy của TodoModel với một vài trường được cập nhật
  TodoModel copyWith({int? id, String? title, bool? isCompleted}) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

```

---


### features/todo/domain/repositories/todo_repository.dart

```dart
// Nếu dùng dartz, bạn sẽ import 'package:dartz/dartz.dart';

import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';

abstract class TodoRepository {
  // Thay vì Future<List<TodoEntity>>, nếu dùng dartz sẽ là:
  // Future<Either<Failure, List<TodoEntity>>> getTodos();
  Future<List<TodoEntity>> getTodos();
  Future<TodoEntity> addTodo(TodoEntity todo);
  Future<TodoEntity> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(int id); // Hoặc Future<Either<Failure, void>>
}

```

---


### features/todo/domain/usecases/add_todo.dart

```dart
// Path: lib/features/todo/domain/usecases/add_todo.dart
import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';
import 'package:bloc_learn/features/todo/domain/repositories/todo_repository.dart';
import 'package:equatable/equatable.dart';

// Nếu dùng dartz: import 'package:dartz/dartz.dart';

class AddTodo implements UseCaseWithParams<TodoEntity, AddTodoParams> {
  final TodoRepository repository;

  AddTodo(this.repository);

  @override
  Future<TodoEntity> call(AddTodoParams params) async {
    // Nếu dùng dartz: Future<Either<Failure, TodoEntity>> call(AddTodoParams params) async {
    final todoEntity = TodoEntity(title: params.title);
    return await repository.addTodo(todoEntity);
  }
}

class AddTodoParams extends Equatable {
  final String title;

  const AddTodoParams({required this.title});

  @override
  List<Object?> get props => [title];
}

```

---


### features/todo/domain/usecases/update_todo.dart

```dart
// Path: lib/features/todo/domain/usecases/update_todo.dart
import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';
import 'package:bloc_learn/features/todo/domain/repositories/todo_repository.dart';
import 'package:equatable/equatable.dart';

// Nếu dùng dartz: import 'package:dartz/dartz.dart';

class UpdateTodo implements UseCaseWithParams<TodoEntity, UpdateTodoParams> {
  final TodoRepository repository;

  UpdateTodo(this.repository);

  @override
  Future<TodoEntity> call(UpdateTodoParams params) async {
    // Nếu dùng dartz: Future<Either<Failure, TodoEntity>> call(UpdateTodoParams params) async {
    return await repository.updateTodo(params.todo);
  }
}

class UpdateTodoParams extends Equatable {
  final TodoEntity todo;

  const UpdateTodoParams({required this.todo});

  @override
  List<Object?> get props => [todo];
}

```

---


### features/todo/domain/usecases/get_todos.dart

```dart
// Path: lib/features/todo/domain/usecases/get_todos.dart

// Nếu dùng dartz: import 'package:dartz/dartz.dart';

import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';
import 'package:bloc_learn/features/todo/domain/repositories/todo_repository.dart';

class GetTodos implements UseCase<List<TodoEntity>, NoParams> {
  final TodoRepository repository;

  GetTodos(this.repository);

  @override
  Future<List<TodoEntity>> call(NoParams params) async {
    // Nếu dùng dartz: Future<Either<Failure, List<TodoEntity>>> call(NoParams params) async {
    return await repository.getTodos();
  }
}

```

---


### features/todo/domain/usecases/delete_todo.dart

```dart
// Path: lib/features/todo/domain/usecases/delete_todo.dart
import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/todo/domain/repositories/todo_repository.dart';
import 'package:equatable/equatable.dart';

// Nếu dùng dartz: import 'package:dartz/dartz.dart';

class DeleteTodo implements UseCaseWithParams<void, DeleteTodoParams> {
  // Nếu dùng dartz: class DeleteTodo implements UseCaseWithParams<void, DeleteTodoParams> {
  // hoặc class DeleteTodo implements UseCase<void, DeleteTodoParams> nếu Usecase chỉ có 1 kiểu
  final TodoRepository repository;

  DeleteTodo(this.repository);

  @override
  Future<void> call(DeleteTodoParams params) async {
    // Nếu dùng dartz: Future<Either<Failure, void>> call(DeleteTodoParams params) async {
    return await repository.deleteTodo(params.id);
  }
}

class DeleteTodoParams extends Equatable {
  final int id;

  const DeleteTodoParams({required this.id});

  @override
  List<Object?> get props => [id];
}

```

---


### features/todo/domain/entities/todo_entity.dart

```dart
// Path: lib/features/todo/domain/entities/todo_entity.dart
import 'package:equatable/equatable.dart';

class TodoEntity extends Equatable {
  final int? id; // id có thể null nếu là todo mới chưa được lưu
  final String title;
  final bool isCompleted;

  const TodoEntity({this.id, required this.title, this.isCompleted = false});

  @override
  List<Object?> get props => [id, title, isCompleted];

  // Helper để tạo bản copy với một vài trường thay đổi
  TodoEntity copyWith({int? id, String? title, bool? isCompleted}) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

```

---


### features/todo/presentation/pages/todo_list_page.dart

```dart
import 'package:bloc_learn/core/theme/bloc/theme_bloc.dart';
import 'package:bloc_learn/core/theme/theme_data.dart';
import 'package:bloc_learn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(LoadTodosEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Todo'),
          content: TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter todo title'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _titleController.clear();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  context.read<TodoBloc>().add(
                    AddTodoEvent(title: _titleController.text),
                  );
                  _titleController.clear();
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List (Clean Arch + BLoC)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.themeMode == AppThemeMode.light
                      ? Icons.wb_sunny
                      : state.themeMode == AppThemeMode.dark
                      ? Icons.nightlight_round
                      : Icons.brightness_auto,
                ),
                onPressed: () {
                  context.read<ThemeBloc>().add(ChangeThemeEvent());
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TodoInitial || state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoLoaded) {
            if (state.todos.isEmpty) {
              return const Center(child: Text('No todos yet! Add one.'));
            }
            return ListView.builder(
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final todo = state.todos[index];
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration:
                          todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (bool? value) {
                      context.read<TodoBloc>().add(
                        ToggleTodoCompletionEvent(todo: todo),
                      );
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      if (todo.id != null) {
                        context.read<TodoBloc>().add(
                          DeleteTodoEvent(id: todo.id!),
                        );
                      }
                    },
                  ),
                );
              },
            );
          } else if (state is TodoError) {
            return Center(
              child: Text(
                'Error: ${state.message}. Pull to refresh or try again.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

```

---


### features/todo/presentation/bloc/todo_bloc.dart

```dart
// Path: lib/features/todo/presentation/bloc/todo_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:bloc_learn/core/error/failures.dart';
import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';
import 'package:bloc_learn/features/todo/domain/usecases/add_todo.dart';
import 'package:bloc_learn/features/todo/domain/usecases/delete_todo.dart';
import 'package:bloc_learn/features/todo/domain/usecases/get_todos.dart';
import 'package:bloc_learn/features/todo/domain/usecases/update_todo.dart';
import 'package:equatable/equatable.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;

  TodoBloc({
    required this.getTodos,
    required this.addTodo,
    required this.updateTodo,
    required this.deleteTodo,
  }) : super(TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoCompletionEvent>(_onToggleTodoCompletion);
    on<DeleteTodoEvent>(_onDeleteTodo);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoading());
    try {
      final todos = await getTodos(NoParams());
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      _handleError(e, emit);
    }
  }

  Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
    // Không cần emit TodoLoading() nếu muốn UI mượt hơn khi thêm
    try {
      await addTodo(AddTodoParams(title: event.title));
      // Sau khi thêm, load lại danh sách todos
      add(LoadTodosEvent()); // Hoặc cập nhật state hiện tại nếu có thể
    } catch (e) {
      _handleError(e, emit, "Failed to add todo: ");
    }
  }

  Future<void> _onToggleTodoCompletion(
    ToggleTodoCompletionEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final updatedTodo = event.todo.copyWith(
        isCompleted: !event.todo.isCompleted,
      );
      await updateTodo(UpdateTodoParams(todo: updatedTodo));
      add(LoadTodosEvent()); // Load lại để thấy thay đổi
    } catch (e) {
      _handleError(e, emit, "Failed to update todo: ");
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await deleteTodo(DeleteTodoParams(id: event.id));
      add(LoadTodosEvent()); // Load lại để thấy thay đổi
    } catch (e) {
      _handleError(e, emit, "Failed to delete todo: ");
    }
  }

  void _handleError(Object e, Emitter<TodoState> emit, [String prefix = ""]) {
    if (e is Failure) {
      emit(TodoError(message: "$prefix${e.message}"));
    } else {
      emit(
        TodoError(
          message: "${prefix}An unexpected error occurred: ${e.toString()}",
        ),
      );
    }
    // Có thể load lại todos ở đây nếu muốn, hoặc để UI xử lý
    // add(LoadTodosEvent());
  }
}

```

---


### features/todo/presentation/bloc/todo_state.dart

```dart
// Path: lib/features/todo/presentation/bloc/todo_state.dart
part of 'todo_bloc.dart'; // Sẽ tạo file todo_bloc.dart sau

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoEntity> todos;

  const TodoLoaded({required this.todos});

  @override
  List<Object?> get props => [todos];
}

class TodoError extends TodoState {
  final String message;

  const TodoError({required this.message});

  @override
  List<Object?> get props => [message];
}

```

---


### features/todo/presentation/bloc/todo_event.dart

```dart
// Path: lib/features/todo/presentation/bloc/todo_event.dart
part of 'todo_bloc.dart'; // Sẽ tạo file todo_bloc.dart sau

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {}

class AddTodoEvent extends TodoEvent {
  final String title;

  const AddTodoEvent({required this.title});

  @override
  List<Object?> get props => [title];
}

class ToggleTodoCompletionEvent extends TodoEvent {
  final TodoEntity todo;

  const ToggleTodoCompletionEvent({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class DeleteTodoEvent extends TodoEvent {
  final int id;

  const DeleteTodoEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

```

---
