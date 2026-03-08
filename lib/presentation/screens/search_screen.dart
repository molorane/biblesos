import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search scriptures...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).set(value);
          },
        ),
      ),
      body: searchResultsAsync.when(
        data: (results) {
          if (results.isEmpty) {
            return const Center(child: Text('Start searching for lyrics or verses'));
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final verse = results[index];
              return ListTile(
                title: Text('${verse.book} ${verse.chapter}:${verse.verse}'),
                subtitle: Text(
                  verse.displayScripture,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
