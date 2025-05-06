// Path: lib/features/todo/domain/entities/todo_entity.dart
import 'package:equatable/equatable.dart';

class TodoEntity extends Equatable {
  final int? id; // id có thể null nếu là todo mới chưa được lưu
  final String title;
  final bool isCompleted;

  const TodoEntity({this.id, required this.title, this.isCompleted = false});

  @override
  List<Object?> get props => [id, title, isCompleted];

  // Helper để tạo bản copy với một vài trường thay đổi
  TodoEntity copyWith({int? id, String? title, bool? isCompleted}) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
