class Book {
  final int id;
  final String name;

  Book({required this.id, required this.name});

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['book'],
    );
  }
}

class VerseSegment {
  final String text;
  final bool isJesusWords;

  VerseSegment(this.text, {this.isJesusWords = false});
}

class Verse {
  final int id;
  final int bookNum;
  final String testament;
  final String book;
  final int chapter;
  final int verse;
  final String? title;
  final String scripture;

  Verse({
    required this.id,
    required this.bookNum,
    required this.testament,
    required this.book,
    required this.chapter,
    required this.verse,
    this.title,
    required this.scripture,
  });

  factory Verse.fromMap(Map<String, dynamic> map, {String? bookName}) {
    return Verse(
      id: map['rowid'] ?? map['id'],
      bookNum: map['book'],
      testament: map['testament'] ?? '',
      book: bookName ?? map['book_name'] ?? '',
      chapter: map['chapter'],
      verse: map['verse'],
      title: map['title'],
      scripture: map['scripture'],
    );
  }

  List<VerseSegment> get segments {
    final parts = scripture.split('@');
    final List<VerseSegment> result = [];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      // Index 0 is normal, 1 is Jesus, 2 is normal, etc.
      result.add(VerseSegment(parts[i], isJesusWords: i % 2 != 0));
    }
    return result;
  }

  String get displayScripture => scripture.replaceAll('@', '');
}

class TextHighlight {
  final int id;
  final int verseId;
  final int startOffset;
  final int endOffset;
  final String color;

  TextHighlight({
    required this.id,
    required this.verseId,
    required this.startOffset,
    required this.endOffset,
    required this.color,
  });

  factory TextHighlight.fromMap(Map<String, dynamic> map) {
    return TextHighlight(
      id: map['id'],
      verseId: map['verse_id'],
      startOffset: map['start_offset'],
      endOffset: map['end_offset'],
      color: map['color'],
    );
  }
}

class Topic {
  final int id;
  final String text;

  Topic({required this.id, required this.text});

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      text: map['text'],
    );
  }
}

class TopicContent {
  final int id;
  final int topicId;
  final String text;

  TopicContent({required this.id, required this.topicId, required this.text});

  factory TopicContent.fromMap(Map<String, dynamic> map) {
    return TopicContent(
      id: map['id'],
      topicId: map['kword_id'],
      text: map['text'],
    );
  }
}

class Translation {
  final String abv;
  final String name;
  final String version;

  Translation({
    required this.abv,
    required this.name,
    required this.version,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      abv: json['abv'] ?? '',
      name: json['name'] ?? '',
      version: json['version'] ?? '',
    );
  }
}
