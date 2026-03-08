import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/select_scripture_screen.dart';
import 'package:biblesos/data/storage_service.dart';
import 'package:biblesos/data/database_service.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late PageController _pageController;
  final Color _primaryGreen = const Color(0xFF4DB66A);

  @override
  void initState() {
    super.initState();
    final initialChapter = ref.read(selectedChapterProvider);
    _pageController = PageController(initialPage: initialChapter - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scrollToSelectedVerse() {
    // This logic needs to be handled per page now.
    // For now, let's keep it simple and scroll the current page if needed.
  }

  @override
  Widget build(BuildContext context) {
    final bookId = ref.watch(selectedBookIdProvider);
    final chapter = ref.watch(selectedChapterProvider);
    final booksAsync = ref.watch(booksProvider);
    final theme = Theme.of(context);

    String bookName = '...';
    if (booksAsync.hasValue && bookId != null) {
      final book = booksAsync.value!.firstWhere((b) => b.id == bookId);
      bookName = book.name;
    }

    final chaptersCountAsync = bookId != null 
        ? ref.watch(chapterCountProvider(bookId))
        : const AsyncValue<int>.loading();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
                icon: Icon(
                  StorageService.isChapterBookmarked(bookId ?? 1, chapter)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: theme.iconTheme.color,
                ),
                onPressed: () async {
                  if (bookId != null) {
                    await StorageService.toggleChapterBookmark(bookId, chapter);
                    setState(() {}); 
                  }
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
                icon: Icon(Icons.volume_up_outlined, color: theme.iconTheme.color),
                onPressed: () {},
              ),
              const Spacer(),
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SelectScriptureScreen()),
                  );
                  final newChapter = ref.read(selectedChapterProvider);
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(newChapter - 1);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${bookName.trim()} $chapter',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: theme.iconTheme.color),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                child: Text(
                  'SESOTHO',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.more_horiz, color: theme.iconTheme.color),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: chaptersCountAsync.when(
        data: (count) {
          if (count == 0) return const Center(child: Text('No chapters found'));
          return PageView.builder(
            controller: _pageController,
            itemCount: count,
            onPageChanged: (index) {
              final newChapter = index + 1;
              if (newChapter != ref.read(selectedChapterProvider)) {
                ref.read(selectedChapterProvider.notifier).set(newChapter);
                if (bookId != null) {
                  DatabaseService().addToHistory(bookId, bookName, newChapter);
                }
              }
            },
            itemBuilder: (context, chapterIndex) {
              return ChapterView(
                bookId: bookId ?? 1,
                chapter: chapterIndex + 1,
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
        error: (err, stack) => Center(child: Text('Error loading chapters: $err')),
      ),
    );
  }
}

class ChapterView extends ConsumerStatefulWidget {
  final int bookId;
  final int chapter;

  const ChapterView({
    super.key,
    required this.bookId,
    required this.chapter,
  });

  @override
  ConsumerState<ChapterView> createState() => _ChapterViewState();
}

class _ChapterViewState extends ConsumerState<ChapterView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerseIfSelected();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToVerseIfSelected() {
    if (!mounted) return;
    final selectedChapter = ref.read(selectedChapterProvider);
    final selectedVerse = ref.read(selectedVerseProvider);
    
    if (selectedChapter == widget.chapter && selectedVerse > 1) {
      double offset = (selectedVerse - 1) * 100.0;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(chaptersVersesProviderFamily(ChaptersVersesParams(widget.bookId, widget.chapter)));
    final theme = Theme.of(context);

    return versesAsync.when(
      data: (verses) {
        if (verses.isEmpty) return const Center(child: Text('Empty chapter'));
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.5,
                    color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '${verse.verse} ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                      ),
                    ),
                    ...verse.segments.map((segment) {
                      return TextSpan(
                        text: segment.text,
                        style: TextStyle(
                          color: segment.isJesusWords ? Colors.red.shade700 : null,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
      ),
      error: (err, stack) => Center(child: Text('Error loading verses: $err')),
    );
  }
}
