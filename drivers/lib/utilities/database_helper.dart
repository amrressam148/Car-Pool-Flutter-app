import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    // If _database is null, initialize it
    _database = await initDatabase('driver_data', 2); // Change name and version here
    return _database!;
  }

  static Future<Database> initDatabase(String dbName, int dbVersion) async {
    String path = join(await getDatabasesPath(), '$dbName.db');
    return await openDatabase(path, version: dbVersion, onCreate: _createTable);
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        address TEXT,
        phone TEXT
      )
    ''');
  }

  static Future<void> insertUser(Map<String, dynamic> userData) async {
    final Database db = await database;

    await db.insert('users', userData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>> getUserData(String userId) async {
    final Database db = await database;
    List<Map<String, dynamic>> results = await db.query('users',
        where: 'id = ?', whereArgs: [userId], limit: 1);

    return results.isNotEmpty ? results[0] : {};
  }
}
