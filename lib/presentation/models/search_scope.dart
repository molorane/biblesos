import 'package:flutter/material.dart';

enum SearchScope {
  wholeBible('Whole Bible', 1, 66, Icons.menu_book),
  oldTestament('Old Testament', 1, 39, Icons.auto_stories),
  newTestament('New Testament', 40, 66, Icons.menu_book_outlined),
  pentateuch('Pentateuch / Torah', 1, 5, Icons.book),
  history('History Books', 6, 17, Icons.history_edu),
  poetry('Poetry & Wisdom', 18, 22, Icons.library_music),
  prophetic('Prophetic Books', 23, 39, Icons.record_voice_over),
  gospels('The Gospels', 40, 43, Icons.people),
  acts('Acts of the Apostles', 44, 44, Icons.directions_walk),
  pauline('Pauline Letters', 45, 57, Icons.mail),
  apostolic('Apostolic Letters', 58, 65, Icons.mark_email_read),
  revelation('Revelation', 66, 66, Icons.remove_red_eye);

  final String label;
  final int startBookId;
  final int endBookId;
  final IconData icon;

  const SearchScope(this.label, this.startBookId, this.endBookId, this.icon);
}
