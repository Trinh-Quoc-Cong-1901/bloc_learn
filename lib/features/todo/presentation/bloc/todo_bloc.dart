// Path: lib/features/todo/presentation/bloc/todo_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:bloc_learn/core/error/failures.dart';
import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';
import 'package:bloc_learn/features/todo/domain/usecases/add_todo.dart';
import 'package:bloc_learn/features/todo/domain/usecases/delete_todo.dart';
import 'package:bloc_learn/features/todo/domain/usecases/get_todos.dart';
import 'package:bloc_learn/features/todo/domain/usecases/update_todo.dart';
import 'package:equatable/equatable.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;

  TodoBloc({
    required this.getTodos,
    required this.addTodo,
    required this.updateTodo,
    required this.deleteTodo,
  }) : super(TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoCompletionEvent>(_onToggleTodoCompletion);
    on<DeleteTodoEvent>(_onDeleteTodo);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoading());
    try {
      final todos = await getTodos(NoParams());
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      _handleError(e, emit);
    }
  }

  Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
    // Không cần emit TodoLoading() nếu muốn UI mượt hơn khi thêm
    try {
      await addTodo(AddTodoParams(title: event.title));
      // Sau khi thêm, load lại danh sách todos
      add(LoadTodosEvent()); // Hoặc cập nhật state hiện tại nếu có thể
    } catch (e) {
      _handleError(e, emit, "Failed to add todo: ");
    }
  }

  Future<void> _onToggleTodoCompletion(
    ToggleTodoCompletionEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final updatedTodo = event.todo.copyWith(
        isCompleted: !event.todo.isCompleted,
      );
      await updateTodo(UpdateTodoParams(todo: updatedTodo));
      add(LoadTodosEvent()); // Load lại để thấy thay đổi
    } catch (e) {
      _handleError(e, emit, "Failed to update todo: ");
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await deleteTodo(DeleteTodoParams(id: event.id));
      add(LoadTodosEvent()); // Load lại để thấy thay đổi
    } catch (e) {
      _handleError(e, emit, "Failed to delete todo: ");
    }
  }

  void _handleError(Object e, Emitter<TodoState> emit, [String prefix = ""]) {
    if (e is Failure) {
      emit(TodoError(message: "$prefix${e.message}"));
    } else {
      emit(
        TodoError(
          message: "${prefix}An unexpected error occurred: ${e.toString()}",
        ),
      );
    }
    // Có thể load lại todos ở đây nếu muốn, hoặc để UI xử lý
    // add(LoadTodosEvent());
  }
}
