import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/data/database_service.dart';
import 'package:sqflite/sqflite.dart';

abstract class BibleRepository {
  Future<List<Book>> getBooks();
  Future<List<Verse>> getChapterVerses(int bookId, int chapter);
  Future<List<Verse>> search(String query);
  Future<void> toggleBookmark(int verseId);
  Future<List<Verse>> getBookmarks();
  Future<void> saveNote(int verseId, String note);
  Future<String?> getNote(int verseId);
  Future<void> addToHistory(int bookId, String bookName, int chapter);
  Future<void> saveHighlight(int verseId, String color);
  Future<Map<int, String>> getHighlights(int bookId, int chapter);
  Future<List<Map<String, dynamic>>> getHistory();
  Future<int> getChapterCount(int bookId);
  Future<int> getVerseCount(int bookId, int chapter);
  Future<Verse?> getVerseByIds(int bookId, int chapter, int verse);
  Future<Map<int, String>> getChapterNotes(int bookId, int chapter);
  Future<void> saveTextHighlight(int verseId, int start, int end, String color);
  Future<void> deleteTextHighlight(int verseId, int start, int end);
  Future<Map<int, List<TextHighlight>>> getTextHighlights(int bookId, int chapter);
}

class BibleRepositoryImpl implements BibleRepository {
  final DatabaseService _dbService = DatabaseService();

  @override
  Future<void> addToHistory(int bookId, String bookName, int chapter) async {
    await _dbService.addToHistory(bookId, bookName, chapter);
  }

  @override
  Future<void> saveHighlight(int verseId, String color) async {
    await _dbService.saveHighlight(verseId, color);
  }

  @override
  Future<Map<int, String>> getHighlights(int bookId, int chapter) async {
    return await _dbService.getHighlights(bookId, chapter);
  }

  @override
  Future<List<Book>> getBooks() async {
    return await _dbService.getBooks();
  }

  @override
  Future<List<Verse>> getChapterVerses(int bookId, int chapter) async {
    return await _dbService.getVerses(bookId, chapter);
  }

  @override
  Future<List<Verse>> search(String query) async {
    return await _dbService.searchScriptures(query);
  }

  @override
  Future<List<Map<String, dynamic>>> getHistory() async {
    return await _dbService.getHistory();
  }

  @override
  Future<int> getChapterCount(int bookId) async {
    return await _dbService.getChapterCount(bookId);
  }

  @override
  Future<int> getVerseCount(int bookId, int chapter) async {
    return await _dbService.getVerseCount(bookId, chapter);
  }

  @override
  Future<Verse?> getVerseByIds(int bookId, int chapter, int verse) async {
    return await _dbService.getVerseByIds(bookId, chapter, verse);
  }

  @override
  Future<void> toggleBookmark(int verseId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> existing = await db.query(
      'bookmarks',
      where: 'verse_id = ?',
      whereArgs: [verseId],
    );

    if (existing.isEmpty) {
      await db.insert('bookmarks', {'verse_id': verseId});
    } else {
      await db.delete('bookmarks', where: 'verse_id = ?', whereArgs: [verseId]);
    }
  }

  @override
  Future<List<Verse>> getBookmarks() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.rowid as id, s.*, bk.book as book_name FROM bible s
      JOIN book bk ON s.book = bk.id
      JOIN bookmarks b ON s.rowid = b.verse_id
    ''');
    return maps.map((m) => Verse.fromMap(m)).toList();
  }

  @override
  Future<void> saveNote(int verseId, String note) async {
    final db = await _dbService.database;
    await db.insert(
      'notes',
      {'verse_id': verseId, 'content': note},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<String?> getNote(int verseId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'verse_id = ?',
      whereArgs: [verseId],
    );
    if (maps.isNotEmpty) {
      return maps.first['content'] as String;
    }
    return null;
  }

  @override
  Future<Map<int, String>> getChapterNotes(int bookId, int chapter) async {
    return await _dbService.getChapterNotes(bookId, chapter);
  }

  @override
  Future<void> saveTextHighlight(int verseId, int start, int end, String color) async {
    await _dbService.saveTextHighlight(verseId, start, end, color);
  }

  @override
  Future<void> deleteTextHighlight(int verseId, int start, int end) async {
    await _dbService.deleteTextHighlight(verseId, start, end);
  }

  @override
  Future<Map<int, List<TextHighlight>>> getTextHighlights(int bookId, int chapter) async {
    return await _dbService.getTextHighlights(bookId, chapter);
  }
}
