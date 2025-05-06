import 'package:bloc_learn/core/error/failures.dart';
import 'package:bloc_learn/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:bloc_learn/features/notes/data/models/note_model.dart';
import 'package:bloc_learn/features/notes/domain/entities/note_entity.dart';
import 'package:bloc_learn/features/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<NoteEntity>> getNotes() async {
    try {
      final noteModels = await localDataSource.getNotes();
      return noteModels;
    } on DatabaseFailure catch (e) {
      rethrow;
    } catch (e) {
      throw ServerFailure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<NoteEntity> addNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final addedNoteModel = await localDataSource.addNote(noteModel);
      return addedNoteModel;
    } on DatabaseFailure catch (e) {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to add note: ${e.toString()}');
    }
  }

  @override
  Future<NoteEntity> updateNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final updatedNoteModel = await localDataSource.updateNote(noteModel);
      return updatedNoteModel;
    } on DatabaseFailure catch (e) {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to update note: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    try {
      await localDataSource.deleteNote(id);
    } on DatabaseFailure catch (e) {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: 'Failed to delete note: ${e.toString()}');
    }
  }
}
