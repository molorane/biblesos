import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/select_scripture_screen.dart';
import 'package:biblesos/presentation/screens/translations_screen.dart';
import 'package:biblesos/data/storage_service.dart';
import 'package:biblesos/data/database_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:biblesos/core/utils/responsive_utils.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late PageController _pageController;
  final Color _primaryGreen = const Color(0xFF4DB66A);
  bool _isProgrammaticJump = false;

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
                    setState(() => _isProgrammaticJump = true);
                    _pageController.jumpToPage(newChapter - 1);
                    // Reset flag after a short delay since jumpToPage/animateToPage 
                    // triggers onPageChanged asynchronously or immediately
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) setState(() => _isProgrammaticJump = false);
                    });
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
              Consumer(
                builder: (context, ref, child) {
                  final translation = ref.watch(selectedTranslationProvider);
                  return TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TranslationsScreen()),
                      );
                    },
                    child: Text(
                      translation.abv.toUpperCase(),
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
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
              final currentChapter = ref.read(selectedChapterProvider);
              
              if (newChapter != currentChapter) {
                ref.read(selectedChapterProvider.notifier).set(newChapter);
                
                // Only reset verse if it was a manual swipe (not a programmatic jump)
                if (!_isProgrammaticJump) {
                  ref.read(selectedVerseProvider.notifier).set(1);
                }
                
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
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _scrollToVerse(int verse) {
    if (!mounted || verse < 1) return;
    
    _itemScrollController.scrollTo(
      index: verse - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  void _showVerseActions(BuildContext context, WidgetRef ref, Verse verse) {
    final theme = Theme.of(context);
    final repo = ref.read(bibleRepositoryProvider);
    final isBookmarked = ref.read(bookmarkIdsProvider).maybeWhen(
      data: (ids) => ids.contains(verse.id),
      orElse: () => false,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '${verse.book} ${verse.chapter}:${verse.verse}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined),
              title: Text(isBookmarked ? 'Remove Bookmark' : 'Add Bookmark'),
              onTap: () async {
                await repo.toggleBookmark(verse.id);
                ref.invalidate(bookmarksProvider);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Copy to Clipboard'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: '${verse.displayScripture}\n\n${verse.book} ${verse.chapter}:${verse.verse}'));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Scripture'),
              onTap: () {
                Share.share('"${verse.displayScripture}"\n\n${verse.book} ${verse.chapter}:${verse.verse}\n\nShared from Bible SOS');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_alt_outlined),
              title: const Text('Take a Note'),
              onTap: () async {
                Navigator.pop(context);
                final note = await repo.getNote(verse.id);
                if (context.mounted) {
                  _showNoteDialog(context, ref, verse, note);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, WidgetRef ref, Verse verse, String? existingNote) {
    final controller = TextEditingController(text: existingNote);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Note: ${verse.book} ${verse.chapter}:${verse.verse}'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Type your note here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DB66A),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(bibleRepositoryProvider).saveNote(verse.id, controller.text);
              ref.invalidate(notesProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note saved')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  TextSpan _buildVerseText(
    Verse verse,
    List<TextHighlight> highlights,
    TextStyle baseStyle,
    bool isSelected,
    Color activeGreen,
    bool wordsOfChristInRed,
  ) {
    final String text = verse.displayScripture;
    final List<TextSpan> finalSpans = [];

    // Add verse number
    finalSpans.add(TextSpan(
      text: '${verse.verse} ',
      style: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * 0.75,
        fontWeight: FontWeight.bold,
        color: isSelected ? activeGreen : Colors.red.shade900,
      ),
    ));

    if (highlights.isEmpty) {
      // Just Jesus words logic
      for (var segment in verse.segments) {
        finalSpans.add(TextSpan(
          text: segment.text,
          style: TextStyle(
            color: (segment.isJesusWords && wordsOfChristInRed) ? Colors.red.shade700 : null,
          ),
        ));
      }
      return TextSpan(children: finalSpans, style: baseStyle);
    }

    // Sort highlights
    final sortedHighlights = List<TextHighlight>.from(highlights)
      ..sort((a, b) => a.startOffset.compareTo(b.startOffset));

    // Handle Jesus segments + Highlights
    // This is complex, let's simplify: Render segments first, then apply highlights as we go
    int currentGlobalOffset = 0;
    for (var segment in verse.segments) {
      final int segmentStart = currentGlobalOffset;
      final int segmentEnd = currentGlobalOffset + segment.text.length;
      final TextStyle segmentStyle = TextStyle(
        color: (segment.isJesusWords && wordsOfChristInRed) ? Colors.red.shade700 : null,
      );

      // Find highlights that overlap with this segment
      final segmentHighlights = sortedHighlights.where((h) => h.startOffset < segmentEnd && h.endOffset > segmentStart).toList();

      if (segmentHighlights.isEmpty) {
        finalSpans.add(TextSpan(text: segment.text, style: segmentStyle));
      } else {
        int inSegmentOffset = 0;
        for (final h in segmentHighlights) {
          final int hStartInSegment = (h.startOffset - segmentStart).clamp(0, segment.text.length);
          final int hEndInSegment = (h.endOffset - segmentStart).clamp(0, segment.text.length);

          if (hStartInSegment > inSegmentOffset) {
            finalSpans.add(TextSpan(
              text: segment.text.substring(inSegmentOffset, hStartInSegment),
              style: segmentStyle,
            ));
          }

          final Color highlightColor = _parseColor(h.color);
          finalSpans.add(TextSpan(
            text: segment.text.substring(hStartInSegment, hEndInSegment),
            style: segmentStyle.copyWith(backgroundColor: highlightColor.withOpacity(0.3)),
          ));
          inSegmentOffset = hEndInSegment;
        }

        if (inSegmentOffset < segment.text.length) {
          finalSpans.add(TextSpan(
            text: segment.text.substring(inSegmentOffset),
            style: segmentStyle,
          ));
        }
      }
      currentGlobalOffset = segmentEnd;
    }

    return TextSpan(children: finalSpans, style: baseStyle);
  }

  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
      }
      return Color(int.parse(colorStr));
    } catch (_) {
      return Colors.yellow;
    }
  }

  void _handleSelection(Verse verse, TextSelection selection) {
    if (selection.isCollapsed) return;
    
    // Account for the verse number prefix in the selectable text
    // The prefix is "${verse.verse} "
    final prefixLength = verse.verse.toString().length + 1;
    
    final start = (selection.start - prefixLength).clamp(0, verse.displayScripture.length);
    final end = (selection.end - prefixLength).clamp(0, verse.displayScripture.length);

    if (start == end) return; // Selection was only on the verse number
    
    _showHighlightPickerDialog(context, verse, start, end);
  }

  void _showHighlightPickerDialog(BuildContext context, Verse verse, int start, int end) {
    final colors = [
      {'name': 'Yellow', 'color': Colors.yellow},
      {'name': 'Green', 'color': Colors.greenAccent},
      {'name': 'Blue', 'color': Colors.blueAccent},
      {'name': 'Pink', 'color': Colors.pinkAccent},
      {'name': 'Purple', 'color': Colors.purpleAccent},
      {'name': 'Remove', 'color': Colors.transparent},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Highlight Selected Text', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors.map((c) {
                final isTransparent = c['color'] == Colors.transparent;
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    if (isTransparent) {
                      await ref.read(bibleRepositoryProvider).deleteTextHighlight(verse.id, start, end);
                    } else {
                      final colorStr = '#${(c['color'] as Color).value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      await ref.read(bibleRepositoryProvider).saveTextHighlight(verse.id, start, end, colorStr);
                    }
                    ref.invalidate(textHighlightsProvider);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c['color'] as Color,
                          shape: BoxShape.circle,
                          border: isTransparent ? Border.all(color: Colors.grey) : null,
                        ),
                        child: isTransparent ? const Icon(Icons.close, size: 20) : null,
                      ),
                      const SizedBox(height: 4),
                      Text(c['name'] as String, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(chaptersVersesProviderFamily(ChaptersVersesParams(widget.bookId, widget.chapter)));
    final notesAsync = ref.watch(notesProvider);
    final bookmarkIdsAsync = ref.watch(bookmarkIdsProvider);
    final textHighlightsAsync = ref.watch(textHighlightsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedVerse = ref.watch(selectedVerseProvider);
    final fontSize = ref.watch(readerFontSizeProvider);
    final fontFamily = ref.watch(readerFontFamilyProvider);
    final wordsOfChristInRed = ref.watch(wordsOfChristInRedProvider);

    // Listen to verse changes to trigger scrolling if we're on the current chapter
    ref.listen<int>(selectedVerseProvider, (previous, next) {
      if (next > 0) {
        _scrollToVerse(next);
      }
    });

    return versesAsync.when(
      data: (verses) {
        final notes = notesAsync.maybeWhen(data: (d) => d, orElse: () => <int, String>{});
        final bookmarkIds = bookmarkIdsAsync.maybeWhen(data: (d) => d, orElse: () => <int>{});
        final textHighlights = textHighlightsAsync.maybeWhen(data: (d) => d, orElse: () => <int, List<TextHighlight>>{});

        return ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          initialScrollIndex: (selectedVerse > 0) ? selectedVerse - 1 : 0,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getHorizontalPadding(context),
            vertical: 10,
          ),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            final isSelected = selectedVerse == verse.verse;
            final hasNote = notes.containsKey(verse.id);
            final isBookmarked = bookmarkIds.contains(verse.id);
            final verseHighlights = textHighlights[verse.id] ?? [];

            return InkWell(
              onTap: () => _showVerseActions(context, ref, verse),
              borderRadius: BorderRadius.circular(8),
              child: SelectionArea(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  margin: const EdgeInsets.only(bottom: 4.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText.rich(
                        _buildVerseText(
                          verse,
                          verseHighlights,
                          GoogleFonts.getFont(
                            fontFamily,
                            fontSize: fontSize,
                            height: 1.6,
                            color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                          ),
                          isSelected,
                          const Color(0xFF4DB66A),
                          wordsOfChristInRed,
                        ),
                        onTap: () => _showVerseActions(context, ref, verse),
                        contextMenuBuilder: (context, editableTextState) {
                          final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
                          buttonItems.insert(0, ContextMenuButtonItem(
                            label: 'Highlight',
                            onPressed: () {
                              editableTextState.hideToolbar();
                              _handleSelection(verse, editableTextState.textEditingValue.selection);
                            },
                          ));
                          return AdaptiveTextSelectionToolbar.buttonItems(
                            anchors: editableTextState.contextMenuAnchors,
                            buttonItems: buttonItems,
                          );
                        },
                      ),
                    if (hasNote || isBookmarked)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            if (isBookmarked)
                              Icon(Icons.bookmark, size: 14, color: Colors.orange.withOpacity(0.7)),
                            if (isBookmarked && hasNote) const SizedBox(width: 8),
                            if (hasNote)
                              Icon(Icons.note_alt, size: 14, color: Colors.blue.withOpacity(0.7)),
                          ],
                        ),
                      ),
                  ],
                ),
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
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      font,
                      style: GoogleFonts.getFont(font, fontSize: 12),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(readerFontFamilyProvider.notifier).set(font);
                      }
                    },
                    selectedColor: const Color(0xFF4DB66A).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF4DB66A),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Words of Christ in Red',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Switch(
                value: ref.watch(wordsOfChristInRedProvider),
                activeColor: const Color(0xFF4DB66A),
                onChanged: (val) => ref.read(wordsOfChristInRedProvider.notifier).set(val),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
