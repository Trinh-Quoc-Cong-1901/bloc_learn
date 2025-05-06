import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/notes/domain/entities/note_entity.dart';
import 'package:bloc_learn/features/notes/domain/repositories/notes_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateNote implements UseCaseWithParams<NoteEntity, UpdateNoteParams> {
  final NotesRepository repository;

  UpdateNote(this.repository);

  @override
  Future<NoteEntity> call(UpdateNoteParams params) async {
    return await repository.updateNote(params.note);
  }
}

class UpdateNoteParams extends Equatable {
  final NoteEntity note;

  const UpdateNoteParams({required this.note});

  @override
  List<Object?> get props => [note];
}
