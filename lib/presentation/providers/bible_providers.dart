import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/data/repositories/bible_repository_impl.dart';
import 'package:biblesos/domain/entities/bible_models.dart';

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
  int? build() => null;
  void set(int? id) => state = id;
}

final selectedBookIdProvider = NotifierProvider<SelectedBookIdNotifier, int?>(
  SelectedBookIdNotifier.new,
);

class SelectedChapterNotifier extends Notifier<int> {
  @override
  int build() => 1;
  void set(int chapter) => state = chapter;
}

final selectedChapterProvider = NotifierProvider<SelectedChapterNotifier, int>(
  SelectedChapterNotifier.new,
);

final chaptersVersesProvider = FutureProvider<List<Verse>>((ref) async {
  final bookId = ref.watch(selectedBookIdProvider);
  final chapter = ref.watch(selectedChapterProvider);
  
  if (bookId == null) return [];
  
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getChapterVerses(bookId, chapter);
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

final historyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getHistory();
});

final highlightsProvider = FutureProvider<Map<int, String>>((ref) async {
  final bookId = ref.watch(selectedBookIdProvider);
  final chapter = ref.watch(selectedChapterProvider);
  if (bookId == null) return {};
  
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getHighlights(bookId, chapter);
});
