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
