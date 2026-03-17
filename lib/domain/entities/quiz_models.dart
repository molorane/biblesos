class Level {
  final int id;
  final String name;
  final String desc;

  Level({
    required this.id,
    required this.name,
    required this.desc,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      name: json['name'],
      desc: json['desc'] ?? '',
    );
  }
}

class Quiz {
  final int id;
  final String text;
  final String color;
  final int durationMinutes;
  final int numOfQuestions;
  final Level? level;

  Quiz({
    required this.id,
    required this.text,
    required this.color,
    required this.durationMinutes,
    required this.numOfQuestions,
    this.level,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      text: json['text'],
      color: json['color'] ?? '#000000',
      durationMinutes: json['durationMinutes'] ?? 0,
      numOfQuestions: json['numOfQuestions'] ?? 0,
      level: json['level'] != null ? Level.fromJson(json['level']) : null,
    );
  }
}

class Question {
  final int id;
  final String text;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.text,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      answers: (json['answers'] as List)
          .map((a) => Answer.fromJson(a))
          .toList(),
    );
  }
}

class Answer {
  final int id;
  final String text;
  final bool isCorrect;

  Answer({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      text: json['text'],
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}

class UserQuizResult {
  final int quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  UserQuizResult({
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory UserQuizResult.fromJson(Map<String, dynamic> json) {
    return UserQuizResult(
      quizId: json['quizId'],
      quizTitle: json['quizTitle'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}
