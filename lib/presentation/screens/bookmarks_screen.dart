import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Verses')),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return const Center(child: Text('You haven\'t saved any verses yet.'));
          }
          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final verse = bookmarks[index];
              return ListTile(
                title: Text('${verse.book} ${verse.chapter}:${verse.verse}'),
                subtitle: Text(verse.displayScripture, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {
                  ref.read(selectedBookIdProvider.notifier).set(verse.bookNum);
                  ref.read(selectedChapterProvider.notifier).set(verse.chapter);
                  ref.read(selectedVerseProvider.notifier).set(verse.verse);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReaderScreen()),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
