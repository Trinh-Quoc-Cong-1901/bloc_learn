import 'package:bloc/bloc.dart';
import 'package:bloc_learn/core/error/failures.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';
import 'package:bloc_learn/features/todo/domain/usecases/search_completed_todos.dart';
import 'package:equatable/equatable.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchCompletedTodos searchCompletedTodos;

  SearchBloc({required this.searchCompletedTodos}) : super(SearchInitial()) {
    on<SearchTodosEvent>(_onSearchTodos);
  }

  Future<void> _onSearchTodos(
    SearchTodosEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.keyword.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final todos = await searchCompletedTodos(
        SearchCompletedTodosParams(keyword: event.keyword),
      );
      if (todos.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchLoaded(todos: todos));
      }
    } catch (e) {
      if (e is Failure) {
        emit(SearchError(message: e.message));
      } else {
        emit(
          SearchError(message: 'An unexpected error occurred: ${e.toString()}'),
        );
      }
    }
  }
}
