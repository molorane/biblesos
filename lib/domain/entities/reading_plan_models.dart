import 'package:flutter/material.dart';

class ReadingPlan {
  final int id;
  final String title;
  final DateTime startDate;
  final List<int> bookOrder; // List of book IDs in the order they should be read
  final int status; // 0: active, 1: completed, 2: archived
  final int durationDays;

  ReadingPlan({
    required this.id,
    required this.title,
    required this.startDate,
    required this.bookOrder,
    this.status = 0,
    required this.durationDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id,
      'title': title,
      'start_date': startDate.toIso8601String(),
      'book_order': bookOrder.join(','),
      'status': status,
      'duration_days': durationDays,
    };
  }

  factory ReadingPlan.fromMap(Map<String, dynamic> map) {
    return ReadingPlan(
      id: map['id'],
      title: map['title'],
      startDate: DateTime.parse(map['start_date']),
      bookOrder: (map['book_order'] as String).split(',').map(int.parse).toList(),
      status: map['status'] ?? 0,
      durationDays: map['duration_days'] ?? 365,
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
  final DateTime? readAt;

  ReadingPlanChapter({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    this.isRead = false,
    this.readAt,
  });

  Map<String, dynamic> toMap(int dayId) {
    return {
      'day_id': dayId,
      'book_id': bookId,
      'book_name': bookName,
      'chapter': chapter,
      'is_read': isRead ? 1 : 0,
      'read_at': readAt?.toIso8601String(),
    };
  }

  factory ReadingPlanChapter.fromMap(Map<String, dynamic> map) {
    return ReadingPlanChapter(
      bookId: map['book_id'],
      bookName: map['book_name'],
      chapter: map['chapter'],
      isRead: map['is_read'] == 1,
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at']) : null,
    );
  }
}

class EfficiencyInfo {
  final double percentage;
  final String description;
  final Color color;
  final int estimatedTimeMinutes;

  EfficiencyInfo({
    required this.percentage,
    required this.description,
    required this.color,
    required this.estimatedTimeMinutes,
  });

  static EfficiencyInfo calculate(int totalChapters, int readChapters, DateTime startDate, int durationDays) {
    if (totalChapters == 0) return EfficiencyInfo(percentage: 0, description: 'N/A', color: Colors.grey, estimatedTimeMinutes: 0);
    
    final daysElapsed = DateTime.now().difference(startDate).inDays;
    if (daysElapsed <= 0) return EfficiencyInfo(percentage: 100, description: 'Just Started', color: Colors.blue, estimatedTimeMinutes: (totalChapters - readChapters) * 4);

    final expectedChapters = (totalChapters / durationDays) * daysElapsed;
    final percentage = (readChapters / expectedChapters) * 100;
    
    // Average reading time per chapter is ~4 minutes
    final remainingTime = (totalChapters - readChapters) * 4;

    if (percentage >= 110) {
      return EfficiencyInfo(percentage: percentage, description: 'Ahead of Schedule', color: Colors.purple, estimatedTimeMinutes: remainingTime);
    } else if (percentage >= 95) {
      return EfficiencyInfo(percentage: percentage, description: 'On Track', color: Colors.green, estimatedTimeMinutes: remainingTime);
    } else if (percentage >= 80) {
      return EfficiencyInfo(percentage: percentage, description: 'Slightly Behind', color: Colors.orange, estimatedTimeMinutes: remainingTime);
    } else {
      return EfficiencyInfo(percentage: percentage, description: 'Behind Schedule', color: Colors.red, estimatedTimeMinutes: remainingTime);
    }
  }
}
