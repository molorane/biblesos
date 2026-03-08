import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';

class BibleBrowserScreen extends ConsumerWidget {
  const BibleBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bible')),
      body: booksAsync.when(
        data: (books) => ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ListTile(
              title: Text(book.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showChapterPicker(context, ref, book.id, book.name);
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showChapterPicker(BuildContext context, WidgetRef ref, int bookId, String bookName) {
    // For this example, we'll just show a grid of chapters.
    // In a real app, we'd query how many chapters are in the book.
    // For demo purposes, we'll assume 50 chapters or something similar, or we can query it.
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Chapter - $bookName', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 50, // Placeholder, usually you query this
                itemBuilder: (context, index) {
                  final chapter = index + 1;
                  return InkWell(
                    onTap: () {
                      ref.read(selectedBookIdProvider.notifier).set(bookId);
                      ref.read(selectedChapterProvider.notifier).set(chapter);
                      Navigator.pop(context); // Close picker
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReaderScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('$chapter'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
