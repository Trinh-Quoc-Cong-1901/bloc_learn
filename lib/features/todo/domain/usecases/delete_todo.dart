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
