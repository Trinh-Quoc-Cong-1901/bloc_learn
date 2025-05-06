import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/notes/domain/repositories/notes_repository.dart';
import 'package:equatable/equatable.dart';

class DeleteNote implements UseCaseWithParams<void, DeleteNoteParams> {
  final NotesRepository repository;

  DeleteNote(this.repository);

  @override
  Future<void> call(DeleteNoteParams params) async {
    return await repository.deleteNote(params.id);
  }
}

class DeleteNoteParams extends Equatable {
  final int id;

  const DeleteNoteParams({required this.id});

  @override
  List<Object?> get props => [id];
}
