import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/theme/app_theme.dart';
import 'package:biblesos/presentation/screens/home_screen.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: BibleSOSApp(),
    ),
  );
}

class BibleSOSApp extends ConsumerWidget {
  const BibleSOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Bible SOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainNavigator(),
    );
  }
}
