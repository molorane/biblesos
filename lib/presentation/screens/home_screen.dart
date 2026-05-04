import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/search_screen.dart';
import 'package:biblesos/presentation/screens/bookmarks_screen.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';
import 'package:biblesos/presentation/screens/settings_screen.dart';
import 'package:biblesos/presentation/screens/converts_screen.dart';
import 'package:biblesos/presentation/screens/tsa_sione_screen.dart';
import 'package:biblesos/presentation/screens/church_hymns_screen.dart';
import 'package:biblesos/presentation/screens/topics_screen.dart';
import 'package:biblesos/presentation/screens/doctrines_screen.dart';
import 'package:biblesos/presentation/screens/quizzes_screen.dart';
import 'package:biblesos/presentation/screens/reading_plan_overview_screen.dart';
import 'package:biblesos/presentation/providers/reading_plan_providers.dart';
import 'package:biblesos/core/utils/responsive_utils.dart';
import 'package:share_plus/share_plus.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sesotho Bible'),
            Text(
              'Buka ea khale',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const VerseOfTheDayCard(),
            const ReadingInsightsCard(),
            const QuickAccessMenu(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class VerseOfTheDayCard extends ConsumerWidget {
  const VerseOfTheDayCard({super.key});

  static const List<String> _bgImages = [
    '1.jpg',
    '2.jpg',
    '5.jpg',
    '7.jpg',
    '8.jpg',
    '9.jpg',
    '10.jpg',
    '11.jpg',
    '12.jpg',
    '13.jpg',
    '14.jpg',
    '15.jpg',
    '14.jpg',
  ];

  String _getSelectedImage() {
    final now = DateTime.now();
    // Use dayOfYear % count for daily rotation
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays;
    return _bgImages[dayOfYear % _bgImages.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final verseAsync = ref.watch(verseOfTheDayProvider);
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    return verseAsync.when(
      data: (verse) {
        if (verse == null) return const SizedBox.shrink();
        
        final verseText = verse.displayScripture;
        final reference = '${verse.book} ${verse.chapter}:${verse.verse}';

        return InkWell(
          onTap: () {
            ref.read(selectedBookIdProvider.notifier).set(verse.bookNum);
            ref.read(selectedChapterProvider.notifier).set(verse.chapter);
            ref.read(selectedVerseProvider.notifier).set(verse.verse);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReaderScreen()),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              image: DecorationImage(
                image: AssetImage('assets/images/${_getSelectedImage()}'),
                fit: BoxFit.cover,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Dark Gradient Overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Glass effect
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 72,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  ),
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 24,
                          left: 24,
                          right: 24,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'VERSE OF THE DAY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Center(
                            child: Text(
                              '"$verseText"',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.crimsonText(
                                color: Colors.white,
                                fontSize: 21,
                                fontStyle: FontStyle.italic,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 72,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              reference,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.share_outlined,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 22,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    Share.share(
                                      '"$verseText"\n\n$reference\nShared from Bible SOS',
                                    );
                                  },
                                ),
                                const SizedBox(width: 20),
                                Icon(
                                  Icons.bookmark_border,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 22,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
        height: 280,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class QuickAccessMenu extends StatelessWidget {
  const QuickAccessMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    final menuItems = [
      _MenuItem(
        label: 'Reading Plan',
        icon: Icons.auto_stories_outlined,
        color: const Color(0xFF4A90E2),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReadingPlanOverviewScreen()),
          );
        },
      ),
      _MenuItem(
        label: 'Daily Manna',
        icon: Icons.coffee_outlined,
        color: const Color(0xFF66BB6A),
        onTap: () async {
          final Uri url = Uri.parse('https://dailymanna.app');
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            // Error handling
          }
        },
      ),
      _MenuItem(
        label: 'Doctrines',
        icon: Icons.account_balance_outlined,
        color: const Color(0xFF4A90E2),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctrinesScreen()),
          );
        },
      ),
      _MenuItem(
        label: 'Topics',
        icon: Icons.topic_outlined,
        color: const Color(0xFF7B7B7B),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TopicsScreen()),
          );
        },
      ),
      _MenuItem(
        label: 'Converts',
        icon: Icons.person_add_outlined,
        color: const Color(0xFFF5A623),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConvertsScreen()),
          );
        },
      ),
      _MenuItem(
        label: 'Hymns',
        icon: Icons.music_note_outlined,
        color: const Color(0xFF7ED321),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChurchHymnsScreen()),
          );
        },
      ),
      _MenuItem(
        label: 'Tsa Sione',
        icon: Icons.library_music_outlined,
        color: const Color(0xFFBD10E0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TsaSioneScreen()),
          );
        },
      ),
      _MenuItem(
        label: 'Quizzes',
        icon: Icons.quiz_outlined,
        color: const Color(0xFFFF7043),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuizzesScreen()),
          );
        },
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtils.getCrossAxisCount(context, phone: 3, tablet: 4, desktop: 8),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: ResponsiveUtils.getCrossAxisCount(context, phone: 1, tablet: 0, desktop: 0) == 1 ? 1.1 : 0.95,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) =>
            _buildMenuTile(context, menuItems[index], isDark),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, _MenuItem item, bool isDark) {
    final isTablet = ResponsiveUtils.getCrossAxisCount(context, phone: 0, tablet: 1, desktop: 1) == 1;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 6),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: isTablet ? 32 : 22),
            ),
            SizedBox(height: isTablet ? 10 : 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 12 : 9,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}


class ReadingInsightsCard extends ConsumerWidget {
  const ReadingInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final coverageAsync = ref.watch(bibleCoverageProvider);
    final upcomingAsync = ref.watch(upcomingChaptersProvider);
    final theme = Theme.of(context);
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReadingPlanOverviewScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF4DB66A), const Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4DB66A).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BIBLE COVERAGE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    coverageAsync.when(
                      data: (coverage) => Text(
                        '${coverage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const SizedBox(height: 38, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                streakAsync.when(
                  data: (streak) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                        Text(
                          '$streak',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: coverageAsync.when(
                data: (coverage) => LinearProgressIndicator(
                  value: coverage / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  color: Colors.white,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: upcomingAsync.when(
                data: (chapters) {
                  if (chapters.isEmpty) {
                    return const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Start a plan to track your journey!',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    );
                  }
                  final first = chapters.first;
                  return Row(
                    children: [
                      const Icon(Icons.auto_stories, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UP NEXT',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${first.bookName} ${first.chapter}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
