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
