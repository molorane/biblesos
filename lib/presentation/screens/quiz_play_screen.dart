import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biblesos/domain/entities/quiz_models.dart';
import 'package:biblesos/presentation/providers/quiz_providers.dart';
import 'package:biblesos/presentation/screens/quiz_result_screen.dart';

class QuizPlayScreen extends ConsumerStatefulWidget {
  final Quiz quiz;

  const QuizPlayScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  int _currentQuestionIndex = 0;
  List<Question> _questions = [];
  Map<int, int> _selectedAnswers = {}; // questionId -> answerId
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.quiz.durationMinutes * 60;
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions = await ref.read(quizQuestionsProvider(widget.quiz.id).future);
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
        if (_remainingSeconds > 0) {
          _startTimer();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _finishQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _finishQuiz() {
    _timer?.cancel();
    
    int score = 0;
    for (var question in _questions) {
      final selectedAnswerId = _selectedAnswers[question.id];
      if (selectedAnswerId != null) {
        final answer = question.answers.firstWhere((a) => a.id == selectedAnswerId);
        if (answer.isCorrect) {
          score++;
        }
      }
    }

    final result = UserQuizResult(
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.text,
      score: score,
      totalQuestions: _questions.length,
      completedAt: DateTime.now(),
    );

    ref.read(pastQuizzesProvider.notifier).addResult(result);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(result: result, quiz: widget.quiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.text)),
        body: const Center(child: Text('No questions found for this quiz.')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.text),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    child: const Text('PREVIOUS'),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _selectedAnswers[currentQuestion.id] == null 
                      ? null 
                      : () {
                          if (_currentQuestionIndex < _questions.length - 1) {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          } else {
                            _finishQuiz();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_currentQuestionIndex < _questions.length - 1 ? 'NEXT' : 'FINISH'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentQuestion.text,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...currentQuestion.answers.map((answer) {
                    final isSelected = _selectedAnswers[currentQuestion.id] == answer.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAnswers[currentQuestion.id] = answer.id;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                              width: 2,
                            ),
                            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  answer.text,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
