part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchTodosEvent extends SearchEvent {
  final String keyword;

  const SearchTodosEvent({required this.keyword});

  @override
  List<Object?> get props => [keyword];
}
