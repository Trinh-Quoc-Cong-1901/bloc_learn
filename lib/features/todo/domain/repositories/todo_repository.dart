// Nếu dùng dartz, bạn sẽ import 'package:dartz/dartz.dart';

import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';

abstract class TodoRepository {
  // Thay vì Future<List<TodoEntity>>, nếu dùng dartz sẽ là:
  // Future<Either<Failure, List<TodoEntity>>> getTodos();
  Future<List<TodoEntity>> getTodos();
  Future<TodoEntity> addTodo(TodoEntity todo);
  Future<TodoEntity> updateTodo(TodoEntity todo);

  Future<void> deleteTodo(int id); // Hoặc Future<Either<Failure, void>>
  Future<List<TodoEntity>> searchCompletedTodos(
    String keyword,
  ); // Thêm dòng này
}
