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
  Future<List<TodoModel>> searchCompletedTodos(String keyword); // Thêm dòng này
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

  @override
  Future<List<TodoModel>> searchCompletedTodos(String keyword) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTodo,
        where:
            '${DatabaseHelper.columnIsCompleted} = ? AND ${DatabaseHelper.columnTitle} LIKE ?',
        whereArgs: [1, '%$keyword%'],
        orderBy: '${DatabaseHelper.columnId} DESC',
      );
      return List.generate(maps.length, (i) {
        return TodoModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw DatabaseFailure(
        message: 'Failed to search completed todos: ${e.toString()}',
      );
    }
  }
}
