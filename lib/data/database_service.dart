import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
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
    String path = p.join(await getDatabasesPath(), 'Sesotho.db');
    bool exists = await databaseExists(path);

    if (!exists) {
      // Creating new copy from assets
      try {
        await Directory(p.dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(p.join('assets', 'db', 'Sesotho.db'));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      // Opening existing database
    }

    // open the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // User data tables
        await db.execute('''
          CREATE TABLE bookmarks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            verse_id INTEGER UNIQUE
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            verse_id INTEGER UNIQUE,
            content TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE highlights (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            verse_id INTEGER UNIQUE,
            color TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER,
            book_name TEXT,
            chapter INTEGER,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(book_id, chapter)
          )
        ''');
      },
    );
  }

  Future<void> addToHistory(int bookId, String bookName, int chapter) async {
    final db = await database;
    await db.insert(
      'history',
      {
        'book_id': bookId,
        'book_name': bookName,
        'chapter': chapter,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT h.* FROM history h
      ORDER BY timestamp DESC
      LIMIT 10
    ''');
  }

  // Helper methods to query basic info
  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('book', orderBy: 'id ASC');
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Verse>> getVerses(int bookId, int chapter) async {
    final db = await database;
    // Join with 'book' table to get book name, use rowid if id is missing in 'bible'
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.rowid as id, b.*, bk.book as book_name 
      FROM bible b
      JOIN book bk ON b.book = bk.id
      WHERE b.book = ? AND b.chapter = ?
      ORDER BY b.verse ASC
    ''', [bookId, chapter]);
    return maps.map((m) => Verse.fromMap(m)).toList();
  }

  Future<List<Verse>> searchScriptures(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.rowid as id, b.*, bk.book as book_name
      FROM bible b
      JOIN book bk ON b.book = bk.id
      WHERE b.scripture LIKE ?
      LIMIT 50
    ''', ['%$query%']);
    return maps.map((m) => Verse.fromMap(m)).toList();
  }
  Future<int> getChapterCount(int bookId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(DISTINCT chapter) as count FROM bible WHERE book = ?',
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
      JOIN bible s ON h.verse_id = s.rowid
      WHERE s.book = ? AND s.chapter = ?
    ''', [bookId, chapter]);
    
    return {for (var m in maps) m['verse_id'] as int: m['color'] as String};
  }
}
