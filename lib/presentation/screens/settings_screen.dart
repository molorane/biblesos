import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/cache_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Mode'),
            subtitle: Text(_themeModeName(themeMode)),
            onTap: () => _showThemeDialog(context, ref, themeMode),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.format_color_text, color: Colors.red),
            title: const Text('Words of Christ in Red'),
            subtitle: const Text('Display Jesus\' words in red color'),
            value: ref.watch(wordsOfChristInRedProvider),
            onChanged: (value) => ref.read(wordsOfChristInRedProvider.notifier).set(value),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Data & Privacy',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Storage & Cache'),
            subtitle: const Text('Manage history, bookmarks and quiz data'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CacheSettingsScreen()),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
          ),
        ],
      ),
    );
  }

  String _themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_themeModeName(mode)),
              value: mode,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).set(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
