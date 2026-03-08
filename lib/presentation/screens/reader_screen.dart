import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:share_plus/share_plus.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  int? _selectedVerseId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(chaptersVersesProvider);
    final highlightsAsync = ref.watch(highlightsProvider);
    final chapter = ref.watch(selectedChapterProvider);

    // Listen for verses being loaded to add to history
    ref.listen(chaptersVersesProvider, (previous, next) {
      if (next.hasValue && next.value!.isNotEmpty) {
        final bookId = ref.read(selectedBookIdProvider);
        if (bookId != null) {
          ref.read(bibleRepositoryProvider).addToHistory(
            bookId, 
            next.value!.first.book, 
            chapter,
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter $chapter'),
        actions: [
          IconButton(icon: const Icon(Icons.text_fields), onPressed: () {}),
        ],
      ),
      body: versesAsync.when(
        data: (verses) {
          final highlights = highlightsAsync.value ?? {};
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final verse = verses[index];
              final isSelected = _selectedVerseId == verse.id;
              final highlightColorStr = highlights[verse.id];
              Color? highlightColor;
              if (highlightColorStr != null) {
                switch (highlightColorStr) {
                  case 'Yellow': highlightColor = Colors.yellow.withValues(alpha: 0.3); break;
                  case 'Green': highlightColor = Colors.green.withValues(alpha: 0.3); break;
                  case 'Blue': highlightColor = Colors.blue.withValues(alpha: 0.3); break;
                  case 'Pink': highlightColor = Colors.pink.withValues(alpha: 0.3); break;
                }
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVerseId = isSelected ? null : verse.id;
                  });
                  if (!isSelected) {
                    _showVerseMenu(context, verse);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Colors.blue.withValues(alpha: 0.1) 
                      : highlightColor ?? Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            fontSize: 18,
                          ),
                      children: [
                        TextSpan(
                          text: '${verse.verse} ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        ...verse.segments.map((s) => TextSpan(
                          text: s.text,
                          style: TextStyle(
                            color: s.isJesusSpeaking ? Colors.red.shade700 : null,
                            fontWeight: s.isJesusSpeaking ? FontWeight.w500 : null,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showVerseMenu(BuildContext context, Verse verse) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${verse.book} ${verse.chapter}:${verse.verse}',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Bookmark'),
              onTap: () async {
                await ref.read(bibleRepositoryProvider).toggleBookmark(verse.id);
                ref.invalidate(bookmarksProvider);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Add Note'),
              onTap: () {
                Navigator.pop(context);
                _showNoteDialog(context, verse);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Share.share('${verse.book} ${verse.chapter}:${verse.verse}\n\n"${verse.displayScripture}"');
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _colorIcon(Colors.yellow, 'Yellow', verse.id),
                _colorIcon(Colors.green, 'Green', verse.id),
                _colorIcon(Colors.blue, 'Blue', verse.id),
                _colorIcon(Colors.pink, 'Pink', verse.id),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _colorIcon(Color color, String colorName, int verseId) {
    return InkWell(
      onTap: () async {
        await ref.read(bibleRepositoryProvider).saveHighlight(verseId, colorName);
        ref.invalidate(highlightsProvider);
        if (mounted) Navigator.pop(context);
      },
      child: CircleAvatar(backgroundColor: color, radius: 15),
    );
  }

  void _showNoteDialog(BuildContext context, Verse verse) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your note here...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(bibleRepositoryProvider).saveNote(verse.id, controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
