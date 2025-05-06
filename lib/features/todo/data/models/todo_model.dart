import 'package:bloc_learn/core/db/database_helper.dart';
import 'package:bloc_learn/features/todo/domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    super.id, // id có thể null khi tạo mới, db sẽ tự gán
    required super.title,
    required super.isCompleted,
  });

  // Factory constructor để tạo TodoModel từ TodoEntity
  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
    );
  }

  // Chuyển đổi từ Map (đọc từ database) sang TodoModel
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map[DatabaseHelper.columnId] as int?,
      title: map[DatabaseHelper.columnTitle] as String,
      isCompleted:
          (map[DatabaseHelper.columnIsCompleted] as int) ==
          1, // SQLite lưu boolean là 0 hoặc 1
    );
  }

  // Chuyển đổi TodoModel sang Map (để ghi vào database)
  Map<String, dynamic> toMap() {
    return {
      // DatabaseHelper.columnId: id, // Không cần id khi insert vì nó tự tăng
      DatabaseHelper.columnTitle: title,
      DatabaseHelper.columnIsCompleted: isCompleted ? 1 : 0,
    };
  }

  // Tạo một bản copy của TodoModel với một vài trường được cập nhật
  TodoModel copyWith({int? id, String? title, bool? isCompleted}) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
