import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reading History'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 64, color: theme.hintColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final DateTime? timestamp = item['timestamp'] != null 
                  ? DateTime.tryParse(item['timestamp']) 
                  : null;
              final timeStr = timestamp != null 
                  ? DateFormat.yMMMd().add_jm().format(timestamp)
                  : '';

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4DB66A).withOpacity(0.1),
                    child: const Icon(Icons.menu_book_outlined, color: Color(0xFF4DB66A), size: 20),
                  ),
                  title: Text(
                    '${item['book_name']} ${item['chapter']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(timeStr, style: TextStyle(fontSize: 12, color: theme.hintColor)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    ref.read(selectedBookIdProvider.notifier).set(item['book_id']);
                    ref.read(selectedChapterProvider.notifier).set(item['chapter']);
                    ref.read(selectedVerseProvider.notifier).set(1);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReaderScreen()),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4DB66A))),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
