import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';
import 'package:bloc_learn/features/todo/domain/repositories/todo_repository.dart';
import 'package:equatable/equatable.dart';

class SearchCompletedTodos
    implements UseCaseWithParams<List<TodoEntity>, SearchCompletedTodosParams> {
  final TodoRepository repository;

  SearchCompletedTodos(this.repository);

  @override
  Future<List<TodoEntity>> call(SearchCompletedTodosParams params) async {
    return await repository.searchCompletedTodos(params.keyword);
  }
}

class SearchCompletedTodosParams extends Equatable {
  final String keyword;

  const SearchCompletedTodosParams({required this.keyword});

  @override
  List<Object?> get props => [keyword];
}
