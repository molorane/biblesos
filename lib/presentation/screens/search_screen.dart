import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';
import 'package:biblesos/presentation/models/search_scope.dart';

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
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              itemCount: SearchScope.values.length,
              itemBuilder: (context, index) {
                final scope = SearchScope.values[index];
                final isSelected = ref.watch(searchScopeProvider) == scope;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Tooltip(
                    message: 'Long press to view books',
                    child: GestureDetector(
                      onLongPress: () {
                        final booksAsync = ref.read(booksProvider);
                        if (booksAsync.value != null) {
                          final books = booksAsync.value!;
                          final scopeBooks = books.where((b) => b.id >= scope.startBookId && b.id <= scope.endBookId).toList();
                          final bookNames = scopeBooks.map((b) => b.name).join(', ');
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('${scope.label} Books'),
                              content: SingleChildScrollView(
                                child: Text(bookNames),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: FilterChip(
                        avatar: Icon(scope.icon, size: 18),
                        label: Text(scope.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(searchScopeProvider.notifier).set(scope);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: searchResultsAsync.when(
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
          ),
        ],
      ),
    );
  }
}
