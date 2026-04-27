import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/domain/entities/reading_plan_models.dart';
import 'package:biblesos/domain/entities/quiz_models.dart';
import 'package:biblesos/data/database_service.dart';
import 'package:biblesos/data/api_service.dart';
import 'package:biblesos/data/storage_service.dart';
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
  Future<List<Translation>> getTranslations();
  Future<void> downloadTranslation(String abv, {void Function(double progress)? onProgress});
  Future<bool> isTranslationDownloaded(String abv);
  Future<void> setActiveTranslation(String abv);
  Future<void> deleteTranslation(String abv);
  
  // Reading Plan
  Future<int> saveReadingPlan(ReadingPlan plan);
  Future<void> saveReadingPlanDay(int planId, int dayNumber, DateTime date, List<ReadingPlanChapter> chapters);
  Future<List<ReadingPlan>> getReadingPlans();
  Future<ReadingPlan?> getActiveReadingPlan();
  Future<List<ReadingPlanDay>> getReadingPlanDays(int planId);
  Future<void> markChapterAsRead(int bookId, int chapter, bool isRead);
  Future<bool> isChapterRead(int bookId, int chapter);
  Future<List<Map<String, dynamic>>> getDailyProgress();
  Future<void> deleteReadingPlan(int planId);
  Future<List<Map<String, dynamic>>> getReadingPlanChapters(int dayId);
  
  // Quiz
  Future<List<Level>> getLevels();
  Future<List<Quiz>> getQuizzesByLevel(int levelId);
  Future<List<Question>> getQuestionsByQuiz(int quizId);
}

class BibleRepositoryImpl implements BibleRepository {
  final DatabaseService _dbService = DatabaseService();
  final ApiService _apiService = ApiService();

  @override
  Future<int> saveReadingPlan(ReadingPlan plan) async {
    return await _dbService.saveReadingPlan(plan.toMap());
  }

  @override
  Future<void> saveReadingPlanDay(int planId, int dayNumber, DateTime date, List<ReadingPlanChapter> chapters) async {
    final dayData = {
      'plan_id': planId,
      'day_number': dayNumber,
      'date': date.toIso8601String(),
    };
    final chaptersData = chapters.map((c) => c.toMap(0)).toList();
    await _dbService.saveReadingPlanDay(dayData, chaptersData);
  }

  @override
  Future<List<ReadingPlan>> getReadingPlans() async {
    final maps = await _dbService.getReadingPlans();
    return maps.map((m) => ReadingPlan.fromMap(m)).toList();
  }

  @override
  Future<ReadingPlan?> getActiveReadingPlan() async {
    final map = await _dbService.getActiveReadingPlan();
    return map != null ? ReadingPlan.fromMap(map) : null;
  }

  @override
  Future<List<ReadingPlanDay>> getReadingPlanDays(int planId) async {
    final dayMaps = await _dbService.getReadingPlanDays(planId);
    final List<ReadingPlanDay> days = [];
    for (var dMap in dayMaps) {
      final chaptersMaps = await _dbService.getReadingPlanChapters(dMap['id']);
      days.add(ReadingPlanDay(
        id: dMap['id'],
        planId: dMap['plan_id'],
        dayNumber: dMap['day_number'],
        date: DateTime.parse(dMap['date']),
        chapters: chaptersMaps.map((c) => ReadingPlanChapter.fromMap(c)).toList(),
      ));
    }
    return days;
  }

  @override
  Future<void> markChapterAsRead(int bookId, int chapter, bool isRead) async {
    await _dbService.markChapterAsRead(bookId, chapter, isRead);
  }

  @override
  Future<bool> isChapterRead(int bookId, int chapter) async {
    return await _dbService.isChapterRead(bookId, chapter);
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyProgress() async {
    return await _dbService.getDailyProgress();
  }

  @override
  Future<void> deleteReadingPlan(int planId) async {
    await _dbService.deleteReadingPlan(planId);
  }

  @override
  Future<List<Map<String, dynamic>>> getReadingPlanChapters(int dayId) async {
    return await _dbService.getReadingPlanChapters(dayId);
  }

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

  @override
  Future<List<Translation>> getTranslations() async {
    try {
      final translations = await _apiService.fetchTranslations();
      // Cache the translations
      await StorageService.setList(
        StorageService.keyTranslationsCache,
        translations.map((t) => {'abv': t.abv, 'name': t.name, 'version': t.version}).toList(),
      );
      return translations;
    } catch (e) {
      // Fallback to cached translations
      final cached = StorageService.getList(StorageService.keyTranslationsCache);
      final List<Translation> result = [];
      
      if (cached != null) {
        result.addAll(cached.map((json) => Translation.fromJson(Map<String, dynamic>.from(json))));
      } else {
        // If no cache, at least return Sesotho as it's always available
        result.add(Translation(abv: 'SESOTHO', name: 'Sesotho Bible', version: '0.0.0'));
      }
      
      // Merge in any persistent downloaded metadata if not already present
      final downloadedMetadata = StorageService.getList(StorageService.keyDownloadedMetadataCache);
      if (downloadedMetadata != null) {
        for (var json in downloadedMetadata) {
          final t = Translation.fromJson(Map<String, dynamic>.from(json));
          if (!result.any((item) => item.abv == t.abv)) {
            result.add(t);
          }
        }
      }
      
      return result;
    }
  }

  @override
  Future<List<Level>> getLevels() async {
    return await _apiService.fetchLevels();
  }

  @override
  Future<List<Quiz>> getQuizzesByLevel(int levelId) async {
    return await _apiService.fetchQuizzesByLevel(levelId);
  }

  @override
  Future<List<Question>> getQuestionsByQuiz(int quizId) async {
    return await _apiService.fetchQuestionsByQuiz(quizId);
  }

  @override
  Future<void> downloadTranslation(String abv, {void Function(double progress)? onProgress}) async {
    final bytes = await _apiService.downloadTranslation(abv, onProgress: onProgress);
    await _dbService.saveDownloadedTranslation(abv, bytes);
    
    // Explicitly add to persistent download metadata cache
    final translations = await getTranslations();
    final translation = translations.firstWhere((t) => t.abv == abv, orElse: () => Translation(abv: abv, name: abv, version: '0.0.0'));
    
    final currentPersistent = StorageService.getList(StorageService.keyDownloadedMetadataCache) ?? [];
    final List<Map<String, dynamic>> updatedPersistent = List<Map<String, dynamic>>.from(currentPersistent.map((e) => Map<String, dynamic>.from(e)));
    
    if (!updatedPersistent.any((t) => t['abv'] == abv)) {
      updatedPersistent.add({'abv': translation.abv, 'name': translation.name, 'version': translation.version});
      await StorageService.setList(StorageService.keyDownloadedMetadataCache, updatedPersistent);
    }
  }

  @override
  Future<void> deleteTranslation(String abv) async {
    if (abv == 'Sesotho' || abv == 'SOS') return; // Cannot delete default
    
    // Delete database file
    await _dbService.deleteTranslation(abv);
    
    // Remove from persistent metadata cache
    final currentPersistent = StorageService.getList(StorageService.keyDownloadedMetadataCache) ?? [];
    final List<Map<String, dynamic>> updatedPersistent = List<Map<String, dynamic>>.from(currentPersistent.map((e) => Map<String, dynamic>.from(e)));
    
    updatedPersistent.removeWhere((t) => t['abv'] == abv);
    await StorageService.setList(StorageService.keyDownloadedMetadataCache, updatedPersistent);
  }

  @override
  Future<bool> isTranslationDownloaded(String abv) async {
    return await _dbService.isTranslationDownloaded(abv);
  }

  @override
  Future<void> setActiveTranslation(String abv) async {
    await _dbService.switchToTranslation(abv);
  }
}
