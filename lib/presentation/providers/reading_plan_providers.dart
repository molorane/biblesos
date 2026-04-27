import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/domain/entities/reading_plan_models.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'dart:math';

final activeReadingPlanProvider = FutureProvider<ReadingPlan?>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return await repo.getActiveReadingPlan();
});

final readingPlanDaysProvider = FutureProvider.family<List<ReadingPlanDay>, int>((ref, planId) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return await repo.getReadingPlanDays(planId);
});

final readingPlanProgressProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return await repo.getDailyProgress();
});

class ReadingPlanController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createPlan({
    required String title,
    required DateTime startDate,
    required List<int> bookOrder,
    required int durationDays,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bibleRepositoryProvider);
      
      // 1. Save Plan metadata
      final plan = ReadingPlan(
        id: 0,
        title: title,
        startDate: startDate,
        bookOrder: bookOrder,
      );
      final planId = await repo.saveReadingPlan(plan);

      // 2. Generate Days and Chapters
      final List<ReadingPlanChapter> allChapters = [];
      final books = await repo.getBooks();
      
      for (int bookId in bookOrder) {
        final bookName = books.firstWhere((b) => b.id == bookId).name;
        final chapterCount = await repo.getChapterCount(bookId);
        for (int i = 1; i <= chapterCount; i++) {
          allChapters.add(ReadingPlanChapter(
            bookId: bookId,
            bookName: bookName,
            chapter: i,
          ));
        }
      }

      // 3. Distribute chapters across days
      final totalChapters = allChapters.length;
      final chaptersPerDay = (totalChapters / durationDays).ceil();
      
      for (int i = 0; i < durationDays; i++) {
        final startIdx = i * chaptersPerDay;
        if (startIdx >= totalChapters) break;
        
        final endIdx = min(startIdx + chaptersPerDay, totalChapters);
        final dayChapters = allChapters.sublist(startIdx, endIdx);
        final dayDate = startDate.add(Duration(days: i));
        
        await repo.saveReadingPlanDay(planId, i + 1, dayDate, dayChapters);
      }

      ref.invalidate(activeReadingPlanProvider);
      ref.invalidate(readingPlanProgressProvider);
    });
  }

  Future<void> markChapterRead(int bookId, int chapter, bool isRead) async {
    final repo = ref.read(bibleRepositoryProvider);
    await repo.markChapterAsRead(bookId, chapter, isRead);
    ref.invalidate(readingPlanProgressProvider);
    ref.invalidate(readingPlanDaysProvider);
    ref.invalidate(readingPlanChaptersProvider);
  }

  Future<void> updatePlan({
    required int planId,
    required String title,
    required DateTime startDate,
    required List<int> bookOrder,
    required int durationDays,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bibleRepositoryProvider);
      
      // 1. Delete old days and chapters for this plan
      // We'll just delete the plan and re-create it with same ID if possible, 
      // or just update metadata and re-generate days.
      // Easiest is to delete days and re-insert.
      await repo.deleteReadingPlan(planId);
      
      // 2. Re-create with the same logic (this will create a new ID, but that's fine as we only have one active)
      await createPlan(
        title: title,
        startDate: startDate,
        bookOrder: bookOrder,
        durationDays: durationDays,
      );
    });
  }

  Future<void> deletePlan(int planId) async {
    final repo = ref.read(bibleRepositoryProvider);
    await repo.deleteReadingPlan(planId);
    ref.invalidate(activeReadingPlanProvider);
    ref.invalidate(readingPlanProgressProvider);
  }
}

final readingPlanControllerProvider = AsyncNotifierProvider<ReadingPlanController, void>(ReadingPlanController.new);

final readingPlanChaptersProvider = FutureProvider.family<List<ReadingPlanChapter>, int>((ref, dayId) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final dayMaps = await repo.getReadingPlanChapters(dayId);
  return dayMaps.map((c) => ReadingPlanChapter.fromMap(c)).toList();
});

final isChapterReadProvider = FutureProvider.family<bool, ({int bookId, int chapter})>((ref, arg) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return await repo.isChapterRead(arg.bookId, arg.chapter);
});
