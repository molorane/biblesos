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
