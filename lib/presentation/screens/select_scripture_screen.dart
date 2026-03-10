import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/domain/entities/bible_models.dart';

class SelectScriptureScreen extends ConsumerStatefulWidget {
  const SelectScriptureScreen({super.key});

  @override
  ConsumerState<SelectScriptureScreen> createState() =>
      _SelectScriptureScreenState();
}

class _SelectScriptureScreenState extends ConsumerState<SelectScriptureScreen> {
  int _selectedTabIndex = 0; // 0: Book, 1: Chapter, 2: Verse
  int? _tempBookId;
  int? _tempChapter;
  int? _tempVerse;
  String? _tempBookName;

  @override
  void initState() {
    super.initState();
    _tempBookId = ref.read(selectedBookIdProvider);
    _tempChapter = ref.read(selectedChapterProvider);
    _tempVerse = ref.read(selectedVerseProvider);

    // Set initial book name from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final books = ref.read(booksProvider).value;
      if (books != null && _tempBookId != null) {
        final book = books.firstWhere((b) => b.id == _tempBookId);
        setState(() {
          _tempBookName = _getAbbr(book.id);
        });
      }
    });
  }

  String _getAbbr(int bookId) {
    final allBooks = [..._otBooks, ..._ntBooks];
    final match = allBooks.firstWhere(
      (b) => b['id'] == bookId,
      orElse: () => {'abbr': '...'},
    );
    return match['abbr'];
  }

  final List<Map<String, dynamic>> _otBooks = [
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

  final List<Map<String, dynamic>> _ntBooks = [
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

  void _onReadPressed() {
    if (_tempBookId != null && _tempChapter != null) {
      ref.read(selectedBookIdProvider.notifier).set(_tempBookId);
      ref.read(selectedChapterProvider.notifier).set(_tempChapter!);
      ref.read(selectedVerseProvider.notifier).set(1);
      Navigator.pop(context);
    }
  }

  void _onVerseSelected(int verse) {
    if (_tempBookId != null && _tempChapter != null) {
      ref.read(selectedBookIdProvider.notifier).set(_tempBookId);
      ref.read(selectedChapterProvider.notifier).set(_tempChapter!);
      ref.read(selectedVerseProvider.notifier).set(verse);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: const Color(0xFF4DB66A),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Scripture',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSelectorHeader(theme, isDark),
          _buildTabs(theme, isDark),
          Expanded(child: _buildContent(booksAsync, theme, isDark)),
        ],
      ),
    );
  }

  Widget _buildSelectorHeader(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.grid_view, color: theme.hintColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _tempBookName != null && _tempChapter != null
                  ? '$_tempBookName $_tempChapter'
                  : 'Select...',
              style: TextStyle(
                fontSize: 18,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _onReadPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DB66A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('READ'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTabItem(0, 'Book', theme, isDark),
          const SizedBox(width: 12),
          _buildTabItem(1, 'Chapter', theme, isDark),
          const SizedBox(width: 12),
          _buildTabItem(2, 'Verse', theme, isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, ThemeData theme, bool isDark) {
    bool selected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF4DB66A) : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? Colors.transparent
              : (isDark ? Colors.white12 : Colors.white),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.circle : Icons.circle_outlined,
              size: 16,
              color: selected ? const Color(0xFF4DB66A) : theme.hintColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF4DB66A)
                    : theme.textTheme.bodyLarge?.color,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<List<Book>> booksAsync,
    ThemeData theme,
    bool isDark,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return booksAsync.when(
          data: (books) => _buildBookGrid(books, theme, isDark),
          loading: () => Center(
            child: CircularProgressIndicator(color: theme.primaryColor),
          ),
          error: (e, s) => Center(
            child: Text(
              'Error: $e',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        );
      case 1:
        return _buildChapterGrid(theme, isDark);
      case 2:
        return _buildVerseGrid(theme, isDark);
      default:
        return Container();
    }
  }

  Widget _buildBookGrid(List<Book> books, ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _buildGridSection(_otBooks, 'Old Testament', theme, isDark),
        const Divider(height: 15),
        _buildGridSection(_ntBooks, 'New Testament', theme, isDark),
      ],
    );
  }

  Widget _buildGridSection(
    List<Map<String, dynamic>> bookData,
    String title,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.hintColor,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: bookData.length,
          itemBuilder: (context, index) {
            final book = bookData[index];
            return InkWell(
              onTap: () {
                setState(() {
                  _tempBookId = book['id'];
                  _tempBookName = book['abbr'];
                  _selectedTabIndex = 1;
                  _tempChapter = 1; // Default
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: book['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  book['abbr'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChapterGrid(ThemeData theme, bool isDark) {
    if (_tempBookId == null)
      return Center(
        child: Text(
          'Select a book first',
          style: TextStyle(color: theme.hintColor),
        ),
      );

    final chaptersAsync = ref.watch(chapterCountProvider(_tempBookId!));

    return chaptersAsync.when(
      data: (count) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          final chapter = index + 1;
          bool selected = _tempChapter == chapter;
          return InkWell(
            onTap: () {
              setState(() {
                _tempChapter = chapter;
                _selectedTabIndex = 2;
                _tempVerse = 1;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF4DB66A)
                    : (isDark ? Colors.white12 : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : (isDark ? Colors.white10 : Colors.grey.shade200),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$chapter',
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      loading: () =>
          Center(child: CircularProgressIndicator(color: theme.primaryColor)),
      error: (e, s) => Center(
        child: Text(
          'Error: $e',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildVerseGrid(ThemeData theme, bool isDark) {
    if (_tempBookId == null || _tempChapter == null)
      return Center(
        child: Text(
          'Select book and chapter first',
          style: TextStyle(color: theme.hintColor),
        ),
      );

    final versesAsync = ref.watch(
      verseCountProvider(ChaptersVersesParams(_tempBookId!, _tempChapter!)),
    );

    return versesAsync.when(
      data: (count) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          final verse = index + 1;
          bool selected = _tempVerse == verse;
          return InkWell(
            onTap: () => _onVerseSelected(verse),
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF4DB66A)
                    : (isDark ? Colors.white12 : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : (isDark ? Colors.white10 : Colors.grey.shade200),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$verse',
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      loading: () =>
          Center(child: CircularProgressIndicator(color: theme.primaryColor)),
      error: (e, s) => Center(
        child: Text(
          'Error: $e',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }
}
