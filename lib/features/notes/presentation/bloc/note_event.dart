import 'package:bloc_learn/features/notes/domain/entities/note_entity.dart';
import 'package:equatable/equatable.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NoteEvent {}

class AddNoteEvent extends NoteEvent {
  final String content;

  const AddNoteEvent({required this.content});

  @override
  List<Object?> get props => [content];
}

class UpdateNoteEvent extends NoteEvent {
  final NoteEntity note;

  const UpdateNoteEvent({required this.note});

  @override
  List<Object?> get props => [note];
}

class DeleteNoteEvent extends NoteEvent {
  final int id;

  const DeleteNoteEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
