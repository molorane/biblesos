import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/core/utils/bible_utils.dart';

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
    return BibleUtils.getAbbr(bookId);
  }


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
        _buildGridSection(BibleUtils.otBooks, 'Old Testament', theme, isDark),
        const Divider(height: 15),
        _buildGridSection(BibleUtils.ntBooks, 'New Testament', theme, isDark),
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
    if (_tempBookId == null) {
      return Center(
        child: Text(
          'Select a book first',
          style: TextStyle(color: theme.hintColor),
        ),
      );
    }

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
    if (_tempBookId == null || _tempChapter == null) {
      return Center(
        child: Text(
          'Select book and chapter first',
          style: TextStyle(color: theme.hintColor),
        ),
      );
    }

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
