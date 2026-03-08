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

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'],
      bookNum: map['book_num'],
      testament: map['testament'],
      book: map['book'],
      chapter: map['chapter'],
      verse: map['verse'],
      title: map['title'],
      scripture: map['scripture'],
    );
  }
}
