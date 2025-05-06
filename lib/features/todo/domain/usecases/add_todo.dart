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
