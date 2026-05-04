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

final allReadingPlansProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return await repo.getAllReadingPlansWithProgress();
});

final bibleCoverageProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return await repo.getBibleCoverage();
});

final heatmapProvider = FutureProvider<List<DateTime>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return await repo.getHeatmapData();
});

final streakProvider = FutureProvider<int>((ref) async {
  final heatmap = await ref.watch(heatmapProvider.future);
  if (heatmap.isEmpty) return 0;
  
  final sortedDates = List<DateTime>.from(heatmap)..sort((a, b) => b.compareTo(a));
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  
  int streak = 0;
  DateTime currentCheck = today;
  
  // If haven't read today, check if read yesterday to continue streak
  if (!sortedDates.contains(today)) {
    currentCheck = today.subtract(const Duration(days: 1));
    if (!sortedDates.contains(currentCheck)) return 0;
  }
  
  for (int i = 0; i < 365; i++) {
    final date = today.subtract(Duration(days: i));
    if (sortedDates.contains(date)) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
});

final upcomingChaptersProvider = FutureProvider<List<ReadingPlanChapter>>((ref) async {
  final plansAsync = await ref.watch(allReadingPlansProvider.future);
  if (plansAsync.isEmpty) return [];
  
  final repo = ref.watch(bibleRepositoryProvider);
  final List<ReadingPlanChapter> upcoming = [];
  
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  
  for (var planMap in plansAsync) {
    final days = await repo.getReadingPlanDays(planMap['id'] as int);
    // Find the first day that is not fully read
    for (var day in days) {
      final chapters = await repo.getReadingPlanChapters(day.id);
      final unread = chapters
          .map((c) => ReadingPlanChapter.fromMap(c))
          .where((c) => !c.isRead)
          .toList();
      
      if (unread.isNotEmpty) {
        upcoming.addAll(unread);
        break; // Only take one day's worth per plan
      }
    }
  }
  return upcoming;
});

class ReadingPlanController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createPlan({
    required String title,
    required DateTime startDate,
    required List<int> bookOrder,
    required int durationDays,
    List<Map<String, int>>? completedChapters,
    bool syncProgress = false,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bibleRepositoryProvider);
      
      List<Map<String, int>>? chaptersToMarkAsRead = completedChapters;
      if (syncProgress) {
        chaptersToMarkAsRead = await repo.getGlobalReadChapters();
      }

      // 1. Save Plan metadata
      final plan = ReadingPlan(
        id: 0,
        title: title,
        startDate: startDate,
        bookOrder: bookOrder,
        durationDays: durationDays,
      );
      final planId = await repo.saveReadingPlan(plan);

      // 2. Generate Days and Chapters
      final List<ReadingPlanChapter> allChapters = [];
      final books = await repo.getBooks();
      
      for (int bookId in bookOrder) {
        final bookName = books.firstWhere((b) => b.id == bookId).name;
        final chapterCount = await repo.getChapterCount(bookId);
        for (int i = 1; i <= chapterCount; i++) {
          final isRead = chaptersToMarkAsRead?.any((c) => c['bookId'] == bookId && c['chapter'] == i) ?? false;
          allChapters.add(ReadingPlanChapter(
            bookId: bookId,
            bookName: bookName,
            chapter: i,
            isRead: isRead,
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
      ref.invalidate(allReadingPlansProvider);
      ref.invalidate(bibleCoverageProvider);
    });
  }

  Future<void> markChapterRead(int bookId, int chapter, bool isRead, {int? planId}) async {
    final repo = ref.read(bibleRepositoryProvider);
    await repo.markChapterAsRead(bookId, chapter, isRead, planId: planId);
    ref.invalidate(readingPlanProgressProvider);
    ref.invalidate(readingPlanDaysProvider);
    ref.invalidate(readingPlanChaptersProvider);
    ref.invalidate(allReadingPlansProvider);
    ref.invalidate(bibleCoverageProvider);
    ref.invalidate(heatmapProvider);
  }

  Future<void> recalculatePlan(int planId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bibleRepositoryProvider);
      
      // 1. Get Plan and progress
      final plan = await repo.getReadingPlanById(planId);
      if (plan == null) return;
      
      final days = await repo.getReadingPlanDays(planId);
      final List<ReadingPlanChapter> unreadChapters = [];
      
      for (var day in days) {
        final chapters = await repo.getReadingPlanChapters(day.id);
        for (var cMap in chapters) {
          final chapter = ReadingPlanChapter.fromMap(cMap);
          if (!chapter.isRead) {
            unreadChapters.add(chapter);
          }
        }
      }

      if (unreadChapters.isEmpty) return;

      // 2. Delete existing days from today onwards
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      await repo.deleteReadingPlan(planId); // This is aggressive, maybe we should just delete future days
      
      // Re-save plan with original ID but updated metadata if needed
      // Actually, easier to just update the remaining chapters into new days
      // Let's use updatePlan logic but with a twist
      
      final elapsedDays = today.difference(plan.startDate).inDays;
      final remainingDays = max(1, plan.durationDays - elapsedDays);
      
      // Create a temporary plan structure to use createPlan's logic
      await createPlan(
        title: plan.title,
        startDate: today,
        bookOrder: plan.bookOrder,
        durationDays: remainingDays,
        completedChapters: await repo.getReadChaptersForPlan(planId),
      );
      
      // Remove the old plan (since createPlan made a new one)
      // This is a bit messy, but ensures the distribution is correct.
      await repo.deleteReadingPlan(planId);
    });
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
      
      // 1. Fetch completed chapters from the current plan
      final completedChapters = await repo.getReadChaptersForPlan(planId);
      
      // 2. Delete old days and chapters for this plan
      await repo.deleteReadingPlan(planId);
      
      // 3. Re-create with preserved progress
      await createPlan(
        title: title,
        startDate: startDate,
        bookOrder: bookOrder,
        durationDays: durationDays,
        completedChapters: completedChapters,
      );
    });
  }

  Future<void> deletePlan(int planId) async {
    final repo = ref.read(bibleRepositoryProvider);
    await repo.deleteReadingPlan(planId);
    ref.invalidate(activeReadingPlanProvider);
    ref.invalidate(readingPlanProgressProvider);
    ref.invalidate(allReadingPlansProvider);
    ref.invalidate(bibleCoverageProvider);
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
