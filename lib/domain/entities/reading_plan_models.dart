class ReadingPlan {
  final int id;
  final String title;
  final DateTime startDate;
  final List<int> bookOrder; // List of book IDs in the order they should be read
  final int status; // 0: active, 1: completed, 2: archived

  ReadingPlan({
    required this.id,
    required this.title,
    required this.startDate,
    required this.bookOrder,
    this.status = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id,
      'title': title,
      'start_date': startDate.toIso8601String(),
      'book_order': bookOrder.join(','),
      'status': status,
    };
  }

  factory ReadingPlan.fromMap(Map<String, dynamic> map) {
    return ReadingPlan(
      id: map['id'],
      title: map['title'],
      startDate: DateTime.parse(map['start_date']),
      bookOrder: (map['book_order'] as String).split(',').map(int.parse).toList(),
      status: map['status'],
    );
  }
}

class ReadingPlanDay {
  final int id;
  final int planId;
  final int dayNumber; // 1, 2, 3...
  final DateTime date;
  final List<ReadingPlanChapter> chapters;

  ReadingPlanDay({
    required this.id,
    required this.planId,
    required this.dayNumber,
    required this.date,
    required this.chapters,
  });

  bool get isCompleted => chapters.every((c) => c.isRead);
  bool get isPartiallyCompleted => chapters.any((c) => c.isRead) && !isCompleted;
}

class ReadingPlanChapter {
  final int bookId;
  final String bookName;
  final int chapter;
  final bool isRead;

  ReadingPlanChapter({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    this.isRead = false,
  });

  Map<String, dynamic> toMap(int dayId) {
    return {
      'day_id': dayId,
      'book_id': bookId,
      'book_name': bookName,
      'chapter': chapter,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory ReadingPlanChapter.fromMap(Map<String, dynamic> map) {
    return ReadingPlanChapter(
      bookId: map['book_id'],
      bookName: map['book_name'],
      chapter: map['chapter'],
      isRead: map['is_read'] == 1,
    );
  }
}
