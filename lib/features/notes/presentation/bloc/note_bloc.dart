import 'package:bloc/bloc.dart';
import 'package:bloc_learn/core/error/failures.dart';
import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/notes/domain/entities/note_entity.dart';
import 'package:bloc_learn/features/notes/domain/usecases/add_note.dart';
import 'package:bloc_learn/features/notes/domain/usecases/delete_note.dart';
import 'package:bloc_learn/features/notes/domain/usecases/get_notes.dart';
import 'package:bloc_learn/features/notes/domain/usecases/update_note.dart';
import 'package:bloc_learn/features/notes/presentation/bloc/note_event.dart';

import 'package:bloc_learn/features/notes/presentation/bloc/note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetNotes getNotes;
  final AddNote addNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;

  NoteBloc({
    required this.getNotes,
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
  }) : super(NoteInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoading());
    try {
      final notes = await getNotes(NoParams());
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      _handleError(e, emit);
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NoteState> emit) async {
    try {
      await addNote(AddNoteParams(content: event.content));
      add(LoadNotesEvent());
    } catch (e) {
      _handleError(e, emit, "Failed to add note: ");
    }
  }

  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await updateNote(UpdateNoteParams(note: event.note));
      add(LoadNotesEvent());
    } catch (e) {
      _handleError(e, emit, "Failed to update note: ");
    }
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await deleteNote(DeleteNoteParams(id: event.id));
      add(LoadNotesEvent());
    } catch (e) {
      _handleError(e, emit, "Failed to delete note: ");
    }
  }

  void _handleError(Object e, Emitter<NoteState> emit, [String prefix = ""]) {
    if (e is Failure) {
      emit(NoteError(message: "$prefix${e.message}"));
    } else {
      emit(
        NoteError(
          message: "${prefix}An unexpected error occurred: ${e.toString()}",
        ),
      );
    }
  }
}
