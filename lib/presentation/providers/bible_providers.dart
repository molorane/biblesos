import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/data/repositories/bible_repository_impl.dart';
import 'package:biblesos/data/repositories/topic_repository.dart';
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/data/storage_service.dart';

// Theme persistence via Hive
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final index = StorageService.getInt(_key);
    if (index != null) {
      return ThemeMode.values[index];
    }
    return ThemeMode.system;
  }

  void set(ThemeMode mode) async {
    state = mode;
    await StorageService.setInt(_key, mode.index);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepositoryImpl();
});

final booksProvider = FutureProvider<List<Book>>((ref) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getBooks();
});

// Using Notifier for state management in Riverpod 3.0
class SelectedBookIdNotifier extends Notifier<int?> {
  @override
  int? build() => StorageService.getLastBookId() ?? 1;
  
  void set(int? id) {
    state = id;
    if (id != null) {
      final currentChapter = ref.read(selectedChapterProvider);
      StorageService.saveLastPosition(id, currentChapter);
    }
  }
}

final selectedBookIdProvider = NotifierProvider<SelectedBookIdNotifier, int?>(
  SelectedBookIdNotifier.new,
);

class SelectedChapterNotifier extends Notifier<int> {
  @override
  int build() => StorageService.getLastChapter();
  
  void set(int chapter) {
    state = chapter;
    final bookId = ref.read(selectedBookIdProvider);
    if (bookId != null) {
      StorageService.saveLastPosition(bookId, chapter);
    }
  }
}

final selectedChapterProvider = NotifierProvider<SelectedChapterNotifier, int>(
  SelectedChapterNotifier.new,
);

class SelectedVerseNotifier extends Notifier<int> {
  @override
  int build() => StorageService.getLastVerse();
  
  void set(int verse) {
    state = verse;
    final bookId = ref.read(selectedBookIdProvider);
    final chapter = ref.read(selectedChapterProvider);
    if (bookId != null) {
      StorageService.saveLastPosition(bookId, chapter, verse: verse);
    }
  }
}

final selectedVerseProvider = NotifierProvider<SelectedVerseNotifier, int>(
  SelectedVerseNotifier.new,
);

class ChaptersVersesParams {
  final int bookId;
  final int chapter;

  ChaptersVersesParams(this.bookId, this.chapter);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChaptersVersesParams &&
          runtimeType == other.runtimeType &&
          bookId == other.bookId &&
          chapter == other.chapter;

  @override
  int get hashCode => bookId.hashCode ^ chapter.hashCode;
}

final chaptersVersesProviderFamily = FutureProvider.family<List<Verse>, ChaptersVersesParams>((ref, params) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getChapterVerses(params.bookId, params.chapter);
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final searchResultsProvider = FutureProvider<List<Verse>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.search(query);
});

final bookmarksProvider = FutureProvider<List<Verse>>((ref) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getBookmarks();
});

final bookmarkIdsProvider = FutureProvider<Set<int>>((ref) async {
  final bookmarks = await ref.watch(bookmarksProvider.future);
  return bookmarks.map((v) => v.id).toSet();
});

final historyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getHistory();
});

final chapterCountProvider = FutureProvider.family<int, int>((ref, bookId) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getChapterCount(bookId);
});

final verseCountProvider = FutureProvider.family<int, ChaptersVersesParams>((ref, params) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getVerseCount(params.bookId, params.chapter);
});

final highlightsProvider = FutureProvider<Map<int, String>>((ref) async {
  final bookId = ref.watch(selectedBookIdProvider);
  final chapter = ref.watch(selectedChapterProvider);
  if (bookId == null) return {};
  
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getHighlights(bookId, chapter);
});

final notesProvider = FutureProvider<Map<int, String>>((ref) async {
  final bookId = ref.watch(selectedBookIdProvider);
  final chapter = ref.watch(selectedChapterProvider);
  if (bookId == null) return {};
  
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getChapterNotes(bookId, chapter);
});

final textHighlightsProvider = FutureProvider<Map<int, List<TextHighlight>>>((ref) async {
  final bookId = ref.watch(selectedBookIdProvider);
  final chapter = ref.watch(selectedChapterProvider);
  if (bookId == null) return {};
  
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getTextHighlights(bookId, chapter);
});

// Reader UI Settings
class ReaderFontSizeNotifier extends Notifier<double> {
  static const _key = 'reader_font_size';
  
  @override
  double build() {
    return StorageService.getDouble(_key) ?? 20.0;
  }

  void set(double size) async {
    state = size;
    await StorageService.setDouble(_key, size);
  }
}

final readerFontSizeProvider = NotifierProvider<ReaderFontSizeNotifier, double>(
  ReaderFontSizeNotifier.new,
);

class ReaderFontFamilyNotifier extends Notifier<String> {
  static const _key = 'reader_font_family';
  
  @override
  String build() {
    return StorageService.getString(_key) ?? 'Crimson Text';
  }

  void set(String family) async {
    state = family;
    await StorageService.setString(_key, family);
  }
}

final readerFontFamilyProvider = NotifierProvider<ReaderFontFamilyNotifier, String>(
  ReaderFontFamilyNotifier.new,
);

class WordsOfChristInRedNotifier extends Notifier<bool> {
  @override
  bool build() {
    return StorageService.getBool(StorageService.keyWordsOfChristInRed, defaultValue: true);
  }

  void set(bool value) async {
    state = value;
    await StorageService.setBool(StorageService.keyWordsOfChristInRed, value);
  }
}

final wordsOfChristInRedProvider = NotifierProvider<WordsOfChristInRedNotifier, bool>(
  WordsOfChristInRedNotifier.new,
);

// Topic Providers
final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepositoryImpl();
});

final allTopicsProvider = FutureProvider<List<Topic>>((ref) async {
  final repository = ref.watch(topicRepositoryProvider);
  return await repository.getTopics();
});

final topicContentProvider = FutureProvider.family<List<TopicContent>, int>((ref, topicId) async {
  final repository = ref.watch(topicRepositoryProvider);
  return await repository.getTopicContent(topicId);
});

class TopicSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final topicSearchQueryProvider = NotifierProvider<TopicSearchQueryNotifier, String>(
  TopicSearchQueryNotifier.new,
);

final searchTopicsProvider = FutureProvider<List<Topic>>((ref) async {
  final query = ref.watch(topicSearchQueryProvider);
  if (query.isEmpty) return [];
  
  final repository = ref.watch(topicRepositoryProvider);
  return await repository.searchTopics(query);
});
