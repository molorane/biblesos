import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/data/repositories/bible_repository_impl.dart';
import 'package:biblesos/domain/entities/quiz_models.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/data/storage_service.dart';

final levelsProvider = FutureProvider<List<Level>>((ref) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getLevels();
});

final quizzesByLevelProvider = FutureProvider.family<List<Quiz>, int>((ref, levelId) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getQuizzesByLevel(levelId);
});

final quizQuestionsProvider = FutureProvider.family<List<Question>, int>((ref, quizId) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return await repository.getQuestionsByQuiz(quizId);
});

class PastQuizzesNotifier extends Notifier<List<UserQuizResult>> {
  static const _key = 'past_results';

  @override
  List<UserQuizResult> build() {
    final resultsJson = StorageService.quizzesBox.get(_key) as List? ?? [];
    return resultsJson.map((json) {
      if (json is String) {
        return UserQuizResult.fromJson(jsonDecode(json));
      }
      return UserQuizResult.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  Future<void> addResult(UserQuizResult result) async {
    final updatedList = [result, ...state];
    state = updatedList;
    await StorageService.quizzesBox.put(_key, updatedList.map((r) => r.toJson()).toList());
  }
}

final pastQuizzesProvider = NotifierProvider<PastQuizzesNotifier, List<UserQuizResult>>(
  PastQuizzesNotifier.new,
);
