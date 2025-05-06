// Path: lib/features/todo/presentation/bloc/todo_event.dart
part of 'todo_bloc.dart'; // Sẽ tạo file todo_bloc.dart sau

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {}

class AddTodoEvent extends TodoEvent {
  final String title;

  const AddTodoEvent({required this.title});

  @override
  List<Object?> get props => [title];
}

class ToggleTodoCompletionEvent extends TodoEvent {
  final TodoEntity todo;

  const ToggleTodoCompletionEvent({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class DeleteTodoEvent extends TodoEvent {
  final int id;

  const DeleteTodoEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
