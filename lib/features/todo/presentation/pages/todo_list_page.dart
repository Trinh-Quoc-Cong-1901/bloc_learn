import 'package:bloc_learn/core/theme/bloc/theme_bloc.dart';
import 'package:bloc_learn/core/theme/theme_data.dart';
import 'package:bloc_learn/features/notes/presentation/bloc/note_bloc.dart';
import 'package:bloc_learn/features/notes/presentation/pages/note_list_page.dart';
import 'package:bloc_learn/features/todo/presentation/bloc/search_bloc.dart';
import 'package:bloc_learn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:bloc_learn/features/todo/presentation/pages/search_completed_todos_page.dart';
import 'package:bloc_learn/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(LoadTodosEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Todo'),
          content: TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter todo title'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _titleController.clear();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  context.read<TodoBloc>().add(
                    AddTodoEvent(title: _titleController.text),
                  );
                  _titleController.clear();
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List (Clean Arch + BLoC)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BlocProvider(
                        create: (_) => sl<SearchBloc>(),
                        child: const SearchCompletedTodosPage(),
                      ),
                ),
              );
            },
            tooltip: 'Search Completed Todos',
          ),
          IconButton(
            icon: const Icon(Icons.note),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BlocProvider(
                        create: (_) => sl<NoteBloc>(),
                        child: const NoteListPage(),
                      ),
                ),
              );
            },
            tooltip: 'View Notes',
          ),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.themeMode == AppThemeMode.light
                      ? Icons.wb_sunny
                      : state.themeMode == AppThemeMode.dark
                      ? Icons.nightlight_round
                      : Icons.brightness_auto,
                ),
                onPressed: () {
                  context.read<ThemeBloc>().add(ChangeThemeEvent());
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TodoInitial || state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoLoaded) {
            if (state.todos.isEmpty) {
              return const Center(child: Text('No todos yet! Add one.'));
            }
            return ListView.builder(
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final todo = state.todos[index];
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration:
                          todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (bool? value) {
                      context.read<TodoBloc>().add(
                        ToggleTodoCompletionEvent(todo: todo),
                      );
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      if (todo.id != null) {
                        context.read<TodoBloc>().add(
                          DeleteTodoEvent(id: todo.id!),
                        );
                      }
                    },
                  ),
                );
              },
            );
          } else if (state is TodoError) {
            return Center(
              child: Text(
                'Error: ${state.message}. Pull to refresh or try again.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
