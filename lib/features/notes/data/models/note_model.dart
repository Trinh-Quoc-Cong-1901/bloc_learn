import 'package:bloc_learn/core/db/database_helper.dart';
import 'package:bloc_learn/features/notes/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({super.id, required super.content});

  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(id: entity.id, content: entity.content);
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map[DatabaseHelper.columnId] as int?,
      content: map['content'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {DatabaseHelper.columnId: id, 'content': content};
  }
}
