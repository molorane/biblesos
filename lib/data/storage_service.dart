import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String settingsBoxName = 'settings';
  static const String bookmarksBoxName = 'bookmarks';
  static const String historyBoxName = 'history';
  static const String quizzesBoxName = 'quizzes';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(bookmarksBoxName);
    await Hive.openBox(historyBoxName);
    await Hive.openBox(quizzesBoxName);
  }

  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box get bookmarksBox => Hive.box(bookmarksBoxName);
  static Box get historyBox => Hive.box(historyBoxName);
  static Box get quizzesBox => Hive.box(quizzesBoxName);

  static const String keyTranslationsCache = 'translations_cache';
  static const String keyDownloadedMetadataCache = 'downloaded_metadata_cache';

  // Settings helpers
  static int? getInt(String key) => settingsBox.get(key);
  static Future<void> setInt(String key, int value) => settingsBox.put(key, value);

  static String? getString(String key) => settingsBox.get(key);
  static Future<void> setString(String key, String value) => settingsBox.put(key, value);

  static double? getDouble(String key) => settingsBox.get(key);
  static Future<void> setDouble(String key, double value) => settingsBox.put(key, value);

  static bool getBool(String key, {bool defaultValue = false}) => settingsBox.get(key) ?? defaultValue;
  static Future<void> setBool(String key, bool value) => settingsBox.put(key, value);

  static List<dynamic>? getList(String key) => settingsBox.get(key);
  static Future<void> setList(String key, List<dynamic> value) => settingsBox.put(key, value);

  // Last Read helpers
  static const String keyLastBookId = 'last_book_id';
  static const String keyLastChapter = 'last_chapter';
  static const String keyLastVerse = 'last_verse';
  static const String keyWordsOfChristInRed = 'words_of_christ_in_red';
  static const String keySelectionViewMode = 'selection_view_mode';
  static const String keyHasDiscoveredToggle = 'has_discovered_toggle';

  static int getLastBookId() => getInt(keyLastBookId) ?? 1; // Default to Genesis
  static int getLastChapter() => getInt(keyLastChapter) ?? 1;
  static int getLastVerse() => getInt(keyLastVerse) ?? 1;

  static Future<void> saveLastPosition(int bookId, int chapter, {int verse = 1}) async {
    await setInt(keyLastBookId, bookId);
    await setInt(keyLastChapter, chapter);
    await setInt(keyLastVerse, verse);
  }

  // Chapter Bookmarks
  static String _chapterBookmarkKey(int bookId, int chapter) => 'bookmark_${bookId}_$chapter';

  static bool isChapterBookmarked(int bookId, int chapter) {
    return bookmarksBox.get(_chapterBookmarkKey(bookId, chapter)) != null;
  }

  static Future<void> toggleChapterBookmark(int bookId, int chapter) async {
    final key = _chapterBookmarkKey(bookId, chapter);
    if (isChapterBookmarked(bookId, chapter)) {
      await bookmarksBox.delete(key);
    } else {
      await bookmarksBox.put(key, DateTime.now().toIso8601String());
    }
  }
}
