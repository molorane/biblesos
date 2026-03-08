import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/search_screen.dart';
import 'package:biblesos/presentation/screens/bookmarks_screen.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';
import 'package:biblesos/presentation/screens/settings_screen.dart';

class MainNavigator extends ConsumerStatefulWidget {
  const MainNavigator({super.key});

  @override
  ConsumerState<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends ConsumerState<MainNavigator> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const HomeContent(),
    const ReaderScreen(),
    const SearchScreen(),
    const BookmarksScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            label: 'Bible',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bible SOS')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Verse of the Day',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                '"Etsoe Morena o ile a rata fatshe hakaalo, a ba a le neela Mora oa hae ea tsoetsoeng a '
                'le mong, hore e mong le e mong ea lumelang ho eena a se ke a timela, '
                'a mpe a be le bophelo bo sa feleng."',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Johanne 3:16',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Reading',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Your reading history will appear here.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text('${item['book_name']} ${item['chapter']}'),
                      onTap: () {
                        ref
                            .read(selectedBookIdProvider.notifier)
                            .set(item['book_id']);
                        ref
                            .read(selectedChapterProvider.notifier)
                            .set(item['chapter']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReaderScreen(),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading history: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
