import 'package:bloc_learn/core/error/failures.dart';
import 'package:bloc_learn/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:bloc_learn/features/todo/data/models/todo_model.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';
import 'package:bloc_learn/features/todo/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TodoEntity>> getTodos() async {
    try {
      final todoModels = await localDataSource.getTodos();
      return todoModels;
    } on DatabaseFailure catch (e) {
      rethrow;
    } catch (e) {
      throw ServerFailure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<TodoEntity> addTodo(TodoEntity todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final addedTodoModel = await localDataSource.addTodo(todoModel);
      return addedTodoModel;
    } on DatabaseFailure catch (e) {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to add todo: ${e.toString()}');
    }
  }

  @override
  Future<TodoEntity> updateTodo(TodoEntity todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final updatedTodoModel = await localDataSource.updateTodo(todoModel);
      return updatedTodoModel;
    } on DatabaseFailure catch (e) {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to update todo: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      await localDataSource.deleteTodo(id);
    } on DatabaseFailure catch (e) {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to delete todo: ${e.toString()}');
    }
  }

  @override
  Future<List<TodoEntity>> searchCompletedTodos(String keyword) async {
    try {
      final todoModels = await localDataSource.searchCompletedTodos(keyword);
      return todoModels;
    } on DatabaseFailure catch (e) {
      rethrow;
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to search completed todos: ${e.toString()}',
      );
    }
  }
}
