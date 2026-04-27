import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/data/storage_service.dart';
import 'package:biblesos/data/database_service.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/providers/quiz_providers.dart';

class CacheSettingsScreen extends ConsumerWidget {
  const CacheSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage & Cache'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Data Management'),
          _buildCacheItem(
            context,
            icon: Icons.history,
            title: 'Clear Reading History',
            subtitle: 'Removes all recently read chapters from Home',
            onTap: () => _confirmClear(
              context,
              'Clear History?',
              'This will remove all your recently read chapters.',
              () async {
                await StorageService.historyBox.clear();
                ref.invalidate(historyProvider);
              },
            ),
          ),
          _buildCacheItem(
            context,
            icon: Icons.bookmarks_outlined,
            title: 'Clear Bookmarks & Highlights',
            subtitle: 'Removes all saved verses and highlights',
            onTap: () => _confirmClear(
              context,
              'Clear Saved Data?',
              'This will permanently delete all your bookmarks, verse notes, and text highlights.',
              () async {
                await StorageService.bookmarksBox.clear();
                // We also need to clear DB tables for highlights and notes
                final db = await DatabaseService().database;
                await db.delete('bookmarks');
                await db.delete('notes');
                await db.delete('text_highlights');
                await db.delete('highlights');
                
                ref.invalidate(bookmarksProvider);
                ref.invalidate(bookmarkIdsProvider);
                ref.invalidate(notesProvider);
                ref.invalidate(textHighlightsProvider);
              },
            ),
          ),
          _buildCacheItem(
            context,
            icon: Icons.quiz_outlined,
            title: 'Clear Quiz Results',
            subtitle: 'Resets all your quiz scores and progress',
            onTap: () => _confirmClear(
              context,
              'Reset Quizzes?',
              'This will delete all your past quiz results and scores.',
              () async {
                await StorageService.quizzesBox.clear();
                ref.invalidate(pastQuizzesProvider);
              },
            ),
          ),
          const Divider(),
          _buildSectionHeader('System Cache'),
          _buildCacheItem(
            context,
            icon: Icons.sync,
            title: 'Reset Translation Metadata',
            subtitle: 'Forces a refresh of available bible translations',
            onTap: () => _confirmClear(
              context,
              'Reset Metadata?',
              'This will clear the cached list of available translations. It will NOT delete your downloaded bibles.',
              () async {
                await StorageService.settingsBox.delete(StorageService.keyTranslationsCache);
                await StorageService.settingsBox.delete(StorageService.keyDownloadedMetadataCache);
                ref.invalidate(translationsProvider);
              },
            ),
          ),
          _buildCacheItem(
            context,
            icon: Icons.settings_backup_restore,
            title: 'Reset App Settings',
            subtitle: 'Font size, theme, and Christ-in-Red preferences',
            onTap: () => _confirmClear(
              context,
              'Reset Settings?',
              'This will reset your theme, font size, and other display preferences to default.',
              () async {
                await StorageService.settingsBox.delete(readerFontSizeProvider.toString());
                await StorageService.settingsBox.delete(readerFontFamilyProvider.toString());
                await StorageService.settingsBox.delete(StorageService.keyWordsOfChristInRed);
                await StorageService.settingsBox.delete('theme_mode');
                
                ref.invalidate(readerFontSizeProvider);
                ref.invalidate(readerFontFamilyProvider);
                ref.invalidate(wordsOfChristInRedProvider);
                ref.invalidate(themeModeProvider);
              },
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Note: Clearing data is permanent and cannot be undone.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red.shade300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4DB66A),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCacheItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }

  void _confirmClear(BuildContext context, String title, String content, Future<void> Function() onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
