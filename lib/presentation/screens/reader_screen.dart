import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _showFontSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const FontSettingsModal(),
    );
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
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: theme.iconTheme.color),
                onSelected: (value) {
                  switch (value) {
                    case 'font':
                      _showFontSettings(context, ref);
                      break;
                    case 'bookmarks':
                      Navigator.pushNamed(context, '/bookmarks');
                      break;
                    case 'favourite':
                      // TODO: Implement favorites
                      break;
                    case 'history':
                      Navigator.pushNamed(context, '/history');
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'font',
                    child: Row(
                      children: [
                        Icon(Icons.font_download_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Font Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'bookmarks',
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Bookmarks'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'favourite',
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border, size: 20),
                        SizedBox(width: 12),
                        Text('Favourites'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 20),
                        SizedBox(width: 12),
                        Text('History'),
                      ],
                    ),
                  ),
                ],
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
                ref.read(selectedVerseProvider.notifier).set(1); // Reset verse on chapter change
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
  final Map<int, GlobalKey> _verseKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerseIfSelected(ref.read(selectedVerseProvider));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToVerseIfSelected(int verse) {
    if (!mounted || verse <= 1) return;
    
    // Give it a short delay to ensure the ListView is rendered
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final key = _verseKeys[verse];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(chaptersVersesProviderFamily(ChaptersVersesParams(widget.bookId, widget.chapter)));
    final theme = Theme.of(context);
    final selectedVerse = ref.watch(selectedVerseProvider);
    final fontSize = ref.watch(readerFontSizeProvider);
    final fontFamily = ref.watch(readerFontFamilyProvider);

    // Listen to verse changes to trigger scrolling
    ref.listen<int>(selectedVerseProvider, (previous, next) {
      if (next > 1) {
        _scrollToVerseIfSelected(next);
      }
    });

    return versesAsync.when(
      data: (verses) {
        if (verses.isEmpty) return const Center(child: Text('Empty chapter'));
        
        // Pre-fill keys
        for (var verse in verses) {
          _verseKeys[verse.verse] ??= GlobalKey();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            final isSelected = selectedVerse == verse.verse;

            return AnimatedContainer(
              key: _verseKeys[verse.verse],
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.getFont(
                    fontFamily,
                    fontSize: fontSize,
                    height: 1.6,
                    color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '${verse.verse} ',
                      style: TextStyle(
                        fontSize: fontSize * 0.9,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF4DB66A) : (theme.textTheme.bodyLarge?.color ?? Colors.black),
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

class FontSettingsModal extends ConsumerWidget {
  const FontSettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fontSize = ref.watch(readerFontSizeProvider);
    final currentFamily = ref.watch(readerFontFamilyProvider);

    final fonts = [
      'Crimson Text',
      'Inter',
      'Lora',
      'Roboto',
      'Playfair Display',
      'Oswald',
      'EB Garamond',
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Font Size',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.format_size, size: 16),
              Expanded(
                child: Slider(
                  value: fontSize,
                  min: 14,
                  max: 36,
                  activeColor: const Color(0xFF4DB66A),
                  onChanged: (val) => ref.read(readerFontSizeProvider.notifier).set(val),
                ),
              ),
              const Icon(Icons.format_size, size: 28),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Font Style',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: fonts.length,
              itemBuilder: (context, index) {
                final font = fonts[index];
                final isSelected = currentFamily == font;
                return GestureDetector(
                  onTap: () => ref.read(readerFontFamilyProvider.notifier).set(font),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4DB66A) : (isDark ? Colors.white12 : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      font,
                      style: GoogleFonts.getFont(
                        font,
                        color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
