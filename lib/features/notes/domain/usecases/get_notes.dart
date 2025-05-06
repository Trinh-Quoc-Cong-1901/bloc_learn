import 'package:bloc_learn/core/usecases/usecase.dart';
import 'package:bloc_learn/features/notes/domain/entities/note_entity.dart';
import 'package:bloc_learn/features/notes/domain/repositories/notes_repository.dart';

class GetNotes implements UseCase<List<NoteEntity>, NoParams> {
  final NotesRepository repository;

  GetNotes(this.repository);

  @override
  Future<List<NoteEntity>> call(NoParams params) async {
    return await repository.getNotes();
  }
}
