import 'package:bloc_learn/core/db/database_helper.dart';
import 'package:bloc_learn/core/error/failures.dart';
import 'package:bloc_learn/features/notes/data/models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> addNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<void> deleteNote(int id);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final DatabaseHelper databaseHelper;

  NotesLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query('notes', orderBy: 'id DESC');
      return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to get notes: ${e.toString()}');
    }
  }

  @override
  Future<NoteModel> addNote(NoteModel note) async {
    try {
      final db = await databaseHelper.database;
      final id = await db.insert('notes', note.toMap());
      return NoteModel(id: id, content: note.content);
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to add note: ${e.toString()}');
    }
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      return note;
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to update note: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to delete note: ${e.toString()}');
    }
  }
}
