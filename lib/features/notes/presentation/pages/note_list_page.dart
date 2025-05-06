import 'package:bloc_learn/features/notes/domain/entities/note_entity.dart';
import 'package:bloc_learn/features/notes/presentation/bloc/note_bloc.dart';
import 'package:bloc_learn/features/notes/presentation/bloc/note_event.dart';
import 'package:bloc_learn/features/notes/presentation/bloc/note_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(LoadNotesEvent());
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Note'),
          content: TextField(
            controller: _contentController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter note content'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _contentController.clear();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (_contentController.text.isNotEmpty) {
                  context.read<NoteBloc>().add(
                    AddNoteEvent(content: _contentController.text),
                  );
                  _contentController.clear();
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateNoteDialog(BuildContext context, NoteEntity note) {
    _contentController.text = note.content;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Note'),
          content: TextField(
            controller: _contentController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter note content'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _contentController.clear();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (_contentController.text.isNotEmpty) {
                  context.read<NoteBloc>().add(
                    UpdateNoteEvent(
                      note: note.copyWith(content: _contentController.text),
                    ),
                  );
                  _contentController.clear();
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
      appBar: AppBar(title: const Text('Notes')),
      body: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NoteInitial || state is NoteLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NoteLoaded) {
            if (state.notes.isEmpty) {
              return const Center(child: Text('No notes yet! Add one.'));
            }
            return ListView.builder(
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return ListTile(
                  title: Text(note.content),
                  onTap: () => _showUpdateNoteDialog(context, note),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      if (note.id != null) {
                        context.read<NoteBloc>().add(
                          DeleteNoteEvent(id: note.id!),
                        );
                      }
                    },
                  ),
                );
              },
            );
          } else if (state is NoteError) {
            return Center(child: Text('Error hdsfhadshfd: ${state.message}'));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
