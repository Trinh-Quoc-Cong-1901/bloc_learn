import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/notes/domain/entities/note_entity.dart';
import 'package:bloc_learn/features/notes/domain/repositories/notes_repository.dart';
import 'package:equatable/equatable.dart';

class AddNote implements UseCaseWithParams<NoteEntity, AddNoteParams> {
  final NotesRepository repository;

  AddNote(this.repository);

  @override
  Future<NoteEntity> call(AddNoteParams params) async {
    final note = NoteEntity(content: params.content);
    return await repository.addNote(note);
  }
}

class AddNoteParams extends Equatable {
  final String content;

  const AddNoteParams({required this.content});

  @override
  List<Object?> get props => [content];
}
