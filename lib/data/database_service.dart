import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/data/storage_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static String? _currentTranslationAbvCache;
  static String get _currentTranslationAbv {
    _currentTranslationAbvCache ??= StorageService.getString('selected_translation_abv') ?? 'SESOTHO';
    return _currentTranslationAbvCache!;
  }
  static set _currentTranslationAbv(String value) {
    _currentTranslationAbvCache = value;
  }

  Future<String> get _localPath async {
    final directory = await getDatabasesPath();
    return directory;
  }

  Future<String> getTranslationPath(String abv) async {
    return p.join(await _localPath, '$abv.db');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase(_currentTranslationAbv);
    return _database!;
  }

  Future<Database> _initDatabase(String abv) async {
    String path = await getTranslationPath(abv);
    bool exists = await databaseExists(path);

    if (!exists) {
      // For the default Sesotho, we copy from assets if it doesn't exist
      if (abv.toUpperCase() == 'SESOTHO' || abv.toUpperCase() == 'SOS' || abv == 'Sesotho') {
        try {
          await Directory(p.dirname(path)).create(recursive: true);
        } catch (_) {}

        ByteData data = await rootBundle.load(p.join('assets', 'db', 'Sesotho.db'));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } else {
        throw Exception('Database for $abv does not exist and is not the default.');
      }
    }

    return await openDatabase(
      path,
      version: 5,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('CREATE INDEX IF NOT EXISTS idx_bible_book_chapter ON bible (book, chapter)');
        }
        if (oldVersion < 3) {
          // User data tables
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
              book_name TEXT,
              chapter INTEGER,
              timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
              UNIQUE(book_id, chapter)
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS text_highlights (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              verse_id INTEGER,
              start_offset INTEGER,
              end_offset INTEGER,
              color TEXT,
              UNIQUE(verse_id, start_offset, end_offset)
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS reading_plans (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              start_date TEXT,
              book_order TEXT,
              status INTEGER DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS reading_plan_days (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              plan_id INTEGER,
              day_number INTEGER,
              date TEXT,
              FOREIGN KEY (plan_id) REFERENCES reading_plans (id) ON DELETE CASCADE
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS reading_plan_chapters (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              day_id INTEGER,
              book_id INTEGER,
              book_name TEXT,
              chapter INTEGER,
              is_read INTEGER DEFAULT 0,
              FOREIGN KEY (day_id) REFERENCES reading_plan_days (id) ON DELETE CASCADE
            )
          ''');
        }
      },
      onCreate: (db, version) async {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_bible_book_chapter ON bible (book, chapter)');
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
          CREATE TABLE text_highlights (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            verse_id INTEGER,
            start_offset INTEGER,
            end_offset INTEGER,
            color TEXT,
            UNIQUE(verse_id, start_offset, end_offset)
          )
        ''');
        await db.execute('''
          CREATE TABLE reading_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            start_date TEXT,
            book_order TEXT,
            status INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE reading_plan_days (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plan_id INTEGER,
            day_number INTEGER,
            date TEXT,
            FOREIGN KEY (plan_id) REFERENCES reading_plans (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE reading_plan_chapters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day_id INTEGER,
            book_id INTEGER,
            book_name TEXT,
            chapter INTEGER,
            is_read INTEGER DEFAULT 0,
            FOREIGN KEY (day_id) REFERENCES reading_plan_days (id) ON DELETE CASCADE
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
    final history = StorageService.historyBox.get('all_history') as List? ?? [];
    final newItem = {
      'book_id': bookId,
      'book_name': bookName,
      'chapter': chapter,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Remove if exists
    final updatedHistory = history.where((item) => 
      item['book_id'] != bookId || item['chapter'] != chapter
    ).toList();
    
    updatedHistory.insert(0, newItem);
    if (updatedHistory.length > 20) updatedHistory.removeLast();
    
    await StorageService.historyBox.put('all_history', updatedHistory);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final history = StorageService.historyBox.get('all_history') as List? ?? [];
    return history.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> toggleBookmark(int verseId) async {
    final list = StorageService.bookmarksBox.get('verse_bookmarks') as List? ?? [];
    if (list.contains(verseId)) {
      list.remove(verseId);
    } else {
      list.add(verseId);
    }
    await StorageService.bookmarksBox.put('verse_bookmarks', list);
  }

  Future<List<Verse>> getBookmarks() async {
    final list = StorageService.bookmarksBox.get('verse_bookmarks') as List? ?? [];
    if (list.isEmpty) return [];
    
    final db = await database;
    final String ids = list.join(',');
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.rowid as id, b.*, bk.book as book_name 
      FROM bible b
      JOIN book bk ON b.book = bk.id
      WHERE b.rowid IN ($ids)
    ''');
    return maps.map((m) => Verse.fromMap(m)).toList();
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

  Future<Verse?> getVerseByIds(int bookId, int chapter, int verse) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.rowid as id, b.*, bk.book as book_name 
      FROM bible b
      JOIN book bk ON b.book = bk.id
      WHERE b.book = ? AND b.chapter = ? AND b.verse = ?
    ''', [bookId, chapter, verse]);
    
    if (maps.isEmpty) return null;
    return Verse.fromMap(maps.first);
  }

  Future<List<Verse>> searchScriptures(String query, {int? startBookId, int? endBookId}) async {
    final db = await database;
    String queryStr = '''
      SELECT b.rowid as id, b.*, bk.book as book_name
      FROM bible b
      JOIN book bk ON b.book = bk.id
      WHERE b.scripture LIKE ?
    ''';
    List<dynamic> args = ['%$query%'];

    if (startBookId != null && endBookId != null) {
      queryStr += ' AND b.book >= ? AND b.book <= ?';
      args.addAll([startBookId, endBookId]);
    }

    queryStr += ' LIMIT 50';

    final List<Map<String, dynamic>> maps = await db.rawQuery(queryStr, args);
    return maps.map((m) => Verse.fromMap(m)).toList();
  }
  Future<int> getChapterCount(int bookId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT MAX(chapter) as count FROM bible WHERE book = ?',
        [bookId]);
    return (result.first['count'] as int?) ?? 1;
  }
  Future<int> getVerseCount(int bookId, int chapter) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM bible WHERE book = ? AND chapter = ?',
        [bookId, chapter]);
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

  Future<Map<int, String>> getChapterNotes(int bookId, int chapter) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT n.verse_id, n.content FROM notes n
      JOIN bible s ON n.verse_id = s.rowid
      WHERE s.book = ? AND s.chapter = ?
    ''', [bookId, chapter]);
    
    return {for (var m in maps) m['verse_id'] as int: m['content'] as String};
  }

  Future<void> saveTextHighlight(int verseId, int start, int end, String color) async {
    final db = await database;

    // Remove any overlapping highlights for this verse to prevent duplicates/overlap bugs
    // Overlap condition: start1 < end2 AND end1 > start2
    await db.delete(
      'text_highlights',
      where: 'verse_id = ? AND start_offset < ? AND end_offset > ?',
      whereArgs: [verseId, end, start],
    );

    await db.insert(
      'text_highlights',
      {
        'verse_id': verseId,
        'start_offset': start,
        'end_offset': end,
        'color': color,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTextHighlight(int verseId, int start, int end) async {
    final db = await database;
    await db.delete(
      'text_highlights',
      where: 'verse_id = ? AND start_offset = ? AND end_offset = ?',
      whereArgs: [verseId, start, end],
    );
  }

  Future<Map<int, List<TextHighlight>>> getTextHighlights(int bookId, int chapter) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT h.* FROM text_highlights h
      JOIN bible s ON h.verse_id = s.rowid
      WHERE s.book = ? AND s.chapter = ?
    ''', [bookId, chapter]);
    
    final Map<int, List<TextHighlight>> result = {};
    for (var m in maps) {
      final highlight = TextHighlight.fromMap(m);
      result.putIfAbsent(highlight.verseId, () => []).add(highlight);
    }
    return result;
  }

  Future<void> saveDownloadedTranslation(String abv, List<int> bytes) async {
    final path = await getTranslationPath(abv);
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<bool> isTranslationDownloaded(String abv) async {
    if (abv.toUpperCase() == 'SESOTHO' || abv.toUpperCase() == 'SOS' || abv == 'Sesotho') return true;
    final path = await getTranslationPath(abv);
    return await File(path).exists();
  }

  Future<void> switchToTranslation(String abv) async {
    if (_currentTranslationAbv == abv) return;
    
    // Check if it exists
    if (!await isTranslationDownloaded(abv)) {
      throw Exception('Translation $abv is not downloaded.');
    }

    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    _currentTranslationAbv = abv;
    // Database will be re-initialized on next access
  }

  Future<void> deleteTranslation(String abv) async {
    if (abv.toUpperCase() == 'SESOTHO' || abv.toUpperCase() == 'SOS' || abv == 'Sesotho') return; // Cannot delete default
    
    final path = await getTranslationPath(abv);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // --- Reading Plan Methods ---

  Future<int> saveReadingPlan(Map<String, dynamic> planData) async {
    final db = await database;
    return await db.insert('reading_plans', planData);
  }

  Future<void> saveReadingPlanDay(Map<String, dynamic> dayData, List<Map<String, dynamic>> chaptersData) async {
    final db = await database;
    await db.transaction((txn) async {
      final dayId = await txn.insert('reading_plan_days', dayData);
      for (var chapter in chaptersData) {
        final chapterData = Map<String, dynamic>.from(chapter);
        chapterData['day_id'] = dayId;
        await txn.insert('reading_plan_chapters', chapterData);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getReadingPlans() async {
    final db = await database;
    return await db.query('reading_plans', orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> getActiveReadingPlan() async {
    final db = await database;
    final plans = await db.query('reading_plans', where: 'status = 0', limit: 1);
    return plans.isNotEmpty ? plans.first : null;
  }

  Future<List<Map<String, dynamic>>> getReadingPlanDays(int planId) async {
    final db = await database;
    return await db.query('reading_plan_days', where: 'plan_id = ?', orderBy: 'day_number ASC', whereArgs: [planId]);
  }

  Future<List<Map<String, dynamic>>> getReadingPlanChapters(int dayId) async {
    final db = await database;
    return await db.query('reading_plan_chapters', where: 'day_id = ?', whereArgs: [dayId]);
  }

  Future<void> markChapterAsRead(int bookId, int chapter, bool isRead) async {
    final db = await database;
    await db.update(
      'reading_plan_chapters',
      {'is_read': isRead ? 1 : 0},
      where: 'book_id = ? AND chapter = ?',
      whereArgs: [bookId, chapter],
    );
  }

  Future<bool> isChapterRead(int bookId, int chapter) async {
    final db = await database;
    final results = await db.query(
      'reading_plan_chapters',
      where: 'book_id = ? AND chapter = ? AND is_read = 1',
      whereArgs: [bookId, chapter],
    );
    return results.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getDailyProgress() async {
    final db = await database;
    // Get summary of read vs total chapters per day for the active plan
    return await db.rawQuery('''
      SELECT d.id, d.day_number, d.date, 
             COUNT(c.id) as total_chapters,
             SUM(c.is_read) as read_chapters
      FROM reading_plan_days d
      JOIN reading_plan_chapters c ON d.id = c.day_id
      JOIN reading_plans p ON d.plan_id = p.id
      WHERE p.status = 0
      GROUP BY d.id
      ORDER BY d.day_number ASC
    ''');
  }

  Future<void> deleteReadingPlan(int planId) async {
    final db = await database;
    await db.delete('reading_plans', where: 'id = ?', whereArgs: [planId]);
  }
}
