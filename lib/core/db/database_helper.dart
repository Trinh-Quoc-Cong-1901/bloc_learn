import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "TodoApp.db";
  // Tăng phiên bản này nếu bạn thay đổi schema (ví dụ: thêm bảng, thêm cột)
  // Nếu _databaseVersion là 1 và ứng dụng đã chạy, _onCreate đã được gọi.
  // Bây giờ bạn thêm bảng notes, bạn cần tăng version để onUpgrade được gọi.
  static const _databaseVersion = 2; // << TĂNG PHIÊN BẢN

  static const tableTodo = 'todos';
  static const tableNotes = 'notes';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnIsCompleted = 'isCompleted';
  static const columnContent = 'content';

  // Private constructor để triển khai singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Chỉ có một tham chiếu duy nhất đến database trong toàn ứng dụng
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Khởi tạo database một cách lười biếng nếu nó chưa tồn tại
    _database = await _initDatabase();
    return _database!;
  }

  // Mở database (và tạo nếu nó chưa tồn tại)
  _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    print("DatabaseHelper: Database path: $path");
    print("DatabaseHelper: Opening database with version: $_databaseVersion");

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // << THÊM HÀM ONUPGRADE
    );
  }

  // Được gọi khi database được tạo lần đầu tiên.
  // Tạo tất cả các bảng cần thiết ở đây.
  Future _onCreate(Database db, int version) async {
    print(
      "DatabaseHelper: _onCreate called. Creating tables for DB version $version...",
    );
    await db.execute('''
      CREATE TABLE $tableTodo (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnIsCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    print("DatabaseHelper: Table '$tableTodo' created.");

    await db.execute('''
      CREATE TABLE $tableNotes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnContent TEXT NOT NULL
      )
    ''');
    print("DatabaseHelper: Table '$tableNotes' created.");
  }

  // Được gọi khi version của database tăng lên (ví dụ: từ 1 lên 2).
  // Dùng để cập nhật schema của database.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print(
      "DatabaseHelper: _onUpgrade called. Migrating from version $oldVersion to $newVersion...",
    );

    // Logic để xử lý các thay đổi schema dựa trên phiên bản cũ và mới
    // Ví dụ: Nếu bảng 'notes' được thêm vào từ version 2
    if (oldVersion < 2) {
      // Sử dụng "IF NOT EXISTS" để an toàn, phòng trường hợp bảng này đã được tạo
      // bằng cách nào đó hoặc nếu logic _onCreate không được gọi đúng cách trước đó.
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableNotes (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnContent TEXT NOT NULL
        )
      ''');
      print("DatabaseHelper: _onUpgrade - Ensured table '$tableNotes' exists.");
    }

    // Nếu có các phiên bản nâng cấp khác, bạn có thể thêm các khối if:
    // if (oldVersion < 3) { /* migrate to version 3 */ }
    // if (oldVersion < 4) { /* migrate to version 4 */ }
  }
}
