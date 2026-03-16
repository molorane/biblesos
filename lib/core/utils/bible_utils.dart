import 'package:flutter/material.dart';

class BibleUtils {
  static const List<Map<String, dynamic>> otBooks = [
    {'id': 1, 'abbr': 'GEN', 'color': Colors.blue},
    {'id': 2, 'abbr': 'EXO', 'color': Colors.blue},
    {'id': 3, 'abbr': 'LEV', 'color': Color(0xFF42A5F5)},
    {'id': 4, 'abbr': 'NUM', 'color': Color(0xFF1E88E5)},
    {'id': 5, 'abbr': 'DEU', 'color': Color(0xFF1565C0)},
    {'id': 6, 'abbr': 'JOS', 'color': Colors.brown},
    {'id': 7, 'abbr': 'JDG', 'color': Color(0xFF6D4C41)},
    {'id': 8, 'abbr': 'RTH', 'color': Color(0xFF4E342E)},
    {'id': 9, 'abbr': '1SA', 'color': Colors.blueGrey},
    {'id': 10, 'abbr': '2SA', 'color': Color(0xFF546E7A)},
    {'id': 11, 'abbr': '1KI', 'color': Color(0xFF455A64)},
    {'id': 12, 'abbr': '2KI', 'color': Color(0xFF37474F)},
    {'id': 13, 'abbr': '1CH', 'color': Color(0xFF263238)},
    {'id': 14, 'abbr': '2CH', 'color': Colors.grey},
    {'id': 15, 'abbr': 'EZR', 'color': Colors.redAccent},
    {'id': 16, 'abbr': 'NEH', 'color': Color(0xFFFF5252)},
    {'id': 17, 'abbr': 'EST', 'color': Color(0xFFD32F2F)},
    {'id': 18, 'abbr': 'JOB', 'color': Colors.indigo},
    {'id': 19, 'abbr': 'PSM', 'color': Color(0xFF3949AB)},
    {'id': 20, 'abbr': 'PRV', 'color': Color(0xFF283593)},
    {'id': 21, 'abbr': 'ECC', 'color': Color(0xFF1A237E)},
    {'id': 22, 'abbr': 'SOS', 'color': Colors.deepPurple},
    {'id': 23, 'abbr': 'ISH', 'color': Colors.teal},
    {'id': 24, 'abbr': 'JER', 'color': Colors.green},
    {'id': 25, 'abbr': 'LAM', 'color': Color(0xFF43A047)},
    {'id': 26, 'abbr': 'EZE', 'color': Color(0xFF00796B)},
    {'id': 27, 'abbr': 'DAN', 'color': Color(0xFF004D40)},
    {'id': 28, 'abbr': 'HOS', 'color': Colors.pinkAccent},
    {'id': 29, 'abbr': 'JOE', 'color': Color(0xFFFF4081)},
    {'id': 30, 'abbr': 'AMO', 'color': Color(0xFFC2185B)},
    {'id': 31, 'abbr': 'OBA', 'color': Colors.pink},
    {'id': 32, 'abbr': 'JON', 'color': Color(0xFFD81B60)},
    {'id': 33, 'abbr': 'MIC', 'color': Color(0xFF66BB6A)},
    {'id': 34, 'abbr': 'NAH', 'color': Color(0xFF43A047)},
    {'id': 35, 'abbr': 'HAB', 'color': Color(0xFF388E3C)},
    {'id': 36, 'abbr': 'ZEP', 'color': Color(0xFF2E7D32)},
    {'id': 37, 'abbr': 'HAG', 'color': Color(0xFF1B5E20)},
    {'id': 38, 'abbr': 'ZEC', 'color': Colors.green},
    {'id': 39, 'abbr': 'MAL', 'color': Color(0xFF81C784)},
  ];

  static const List<Map<String, dynamic>> ntBooks = [
    {'id': 40, 'abbr': 'MAT', 'color': Color(0xFF42A5F5)},
    {'id': 41, 'abbr': 'MRK', 'color': Colors.blue},
    {'id': 42, 'abbr': 'LUK', 'color': Color(0xFF1E88E5)},
    {'id': 43, 'abbr': 'JHN', 'color': Color(0xFF1565C0)},
    {'id': 44, 'abbr': 'ACT', 'color': Color(0xFF0D47A1)},
    {'id': 45, 'abbr': 'ROM', 'color': Colors.redAccent},
    {'id': 46, 'abbr': '1CR', 'color': Color(0xFFFF5252)},
    {'id': 47, 'abbr': '2CR', 'color': Colors.pinkAccent},
    {'id': 48, 'abbr': 'GAL', 'color': Color(0xFFFF4081)},
    {'id': 49, 'abbr': 'EPH', 'color': Color(0xFFC2185B)},
    {'id': 50, 'abbr': 'PHI', 'color': Colors.pink},
    {'id': 51, 'abbr': 'COL', 'color': Color(0xFFAD1457)},
    {'id': 52, 'abbr': '1TH', 'color': Colors.brown},
    {'id': 53, 'abbr': '2TH', 'color': Color(0xFF4E342E)},
    {'id': 54, 'abbr': '1TI', 'color': Colors.orangeAccent},
    {'id': 55, 'abbr': '2TI', 'color': Color(0xFFFFAB40)},
    {'id': 56, 'abbr': 'TIT', 'color': Colors.indigo},
    {'id': 57, 'abbr': 'PHM', 'color': Color(0xFF5C6BC0)},
    {'id': 58, 'abbr': 'HEB', 'color': Color(0xFF303F9F)},
    {'id': 59, 'abbr': 'JAM', 'color': Colors.deepOrange},
    {'id': 60, 'abbr': '1PE', 'color': Colors.redAccent},
    {'id': 61, 'abbr': '2PE', 'color': Color(0xFFD32F2F)},
    {'id': 62, 'abbr': '1JN', 'color': Colors.blueGrey},
    {'id': 63, 'abbr': '2JN', 'color': Color(0xFF546E7A)},
    {'id': 64, 'abbr': '3JN', 'color': Color(0xFF37474F)},
    {'id': 65, 'abbr': 'JUD', 'color': Color(0xFF1A237E)},
    {'id': 66, 'abbr': 'REV', 'color': Colors.blueGrey},
  ];

  static String getAbbr(int bookId) {
    final allBooks = [...otBooks, ...ntBooks];
    final match = allBooks.firstWhere(
      (b) => b['id'] == bookId,
      orElse: () => {'abbr': '...'},
    );
    return match['abbr'];
  }
}
