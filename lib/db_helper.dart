import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('checadas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE checadas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario TEXT,
            empresa TEXT,
            fecha TEXT,
            hora TEXT,
            longitud REAL,
            latitud REAL,
            id_usuario INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertChecada(Map<String, dynamic> checada) async {
    final db = await database;
    return await db.insert('checadas', checada);
  }

  Future<List<Map<String, dynamic>>> getChecadas() async {
    final db = await database;
    return await db.query('checadas');
  }

  Future<int> deleteChecada(int id) async {
    final db = await database;
    return await db.delete('checadas', where: 'id = ?', whereArgs: [id]);
  }
}
