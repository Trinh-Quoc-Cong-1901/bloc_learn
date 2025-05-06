import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final int? id;
  final String content;

  const NoteEntity({this.id, required this.content});

  @override
  List<Object?> get props => [id, content];

  // Thêm phương thức copyWith
  NoteEntity copyWith({int? id, String? content}) {
    return NoteEntity(id: id ?? this.id, content: content ?? this.content);
  }
}
