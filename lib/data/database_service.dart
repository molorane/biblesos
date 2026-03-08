import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:biblesos/domain/entities/bible_models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "sso.db");

    // Check if the database exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // Creating new copy from assets

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from assets
      ByteData data = await rootBundle.load(join("assets", "sso.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      // Opening existing database
    }

    // open the database
    final db = await openDatabase(path, readOnly: false);

    // Create user data tables if they don't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER UNIQUE,
        content TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER UNIQUE,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER,
        chapter INTEGER,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    return db;
  }

  Future<void> addToHistory(int bookId, int chapter) async {
    final db = await database;
    await db.insert('history', {
      'book_id': bookId,
      'chapter': chapter,
    });
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT h.*, b.book as book_name FROM history h
      JOIN books b ON h.book_id = b.id
      ORDER BY timestamp DESC
      LIMIT 10
    ''');
  }

  // Helper methods to query basic info
  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books', orderBy: 'id ASC');
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Verse>> getVerses(int bookId, int chapter) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scriptures',
      where: 'book_num = ? AND chapter = ?',
      whereArgs: [bookId, chapter],
      orderBy: 'verse ASC',
    );
    return maps.map((m) => Verse.fromMap(m)).toList();
  }

  Future<List<Verse>> searchScriptures(String query) async {
    final db = await database;
    // Basic LIKE search for now, can upgrade to FTS later
    final List<Map<String, dynamic>> maps = await db.query(
      'scriptures',
      where: 'scripture LIKE ?',
      whereArgs: ['%$query%'],
      limit: 50,
    );
    return maps.map((m) => Verse.fromMap(m)).toList();
  }
  Future<int> getChapterCount(int bookId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(DISTINCT chapter) as count FROM scriptures WHERE book_num = ?',
        [bookId]);
    return result.first['count'] as int;
  }
  Future<void> saveHighlight(int verseId, String color) async {
    final db = await database;
    await db.insert(
      'highlights',
      {'verse_id': verseId, 'color': color},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<int, String>> getHighlights(int bookId, int chapter) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT h.verse_id, h.color FROM highlights h
      JOIN scriptures s ON h.verse_id = s.id
      WHERE s.book_num = ? AND s.chapter = ?
    ''', [bookId, chapter]);
    
    return {for (var m in maps) m['verse_id'] as int: m['color'] as String};
  }
}
