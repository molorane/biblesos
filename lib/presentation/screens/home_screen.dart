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
            const VerseOfTheDayCard(),
            const QuickAccessMenu(),
            const DailyMannaButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class VerseOfTheDayCard extends StatelessWidget {
  const VerseOfTheDayCard({super.key});

  static const List<String> _bgImages = [
    '1.jpg', '2.jpg', '5.jpg', '7.jpg', '8.jpg', '9.jpg',
    '10.jpg', '11.jpg', '12.jpg', '13.jpg', '14.jpg', '15.jpg'
  ];

  String _getSelectedImage() {
    final now = DateTime.now();
    // Use dayOfYear % count for daily rotation
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays;
    return _bgImages[dayOfYear % _bgImages.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 240,
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
              height: 64,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          '"Etsoe Morena o ile a rata fatshe hakaalo, a ba a le neela Mora oa hae ea tsoetsoeng a '
                          'le mong, hore e mong le e mong ea lumelang ho eena a se ke a timela, '
                          'a mpe a be le bophelo bo sa feleng."',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.crimsonText(
                            color: Colors.white,
                            fontSize: 19,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Johanne 3:16',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.share_outlined, color: Colors.white.withOpacity(0.9), size: 20),
                          const SizedBox(width: 16),
                          Icon(Icons.bookmark_border, color: Colors.white.withOpacity(0.9), size: 20),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAccessMenu extends StatelessWidget {
  const QuickAccessMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final menuItems = [
      _MenuItem(
        label: 'Doctrines',
        icon: Icons.account_balance_outlined,
        color: const Color(0xFF4A90E2),
        onTap: () {},
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
        label: 'History',
        icon: Icons.history,
        color: const Color(0xFF7B7B7B),
        onTap: () {},
      ),
      _MenuItem(
        label: 'Bookmarks',
        icon: Icons.bookmark_outline,
        color: const Color(0xFFE91E63),
        onTap: () {},
      ),
      _MenuItem(
        label: 'Hymns',
        icon: Icons.music_note_outlined,
        color: const Color(0xFF7ED321),
        onTap: () {},
      ),
      _MenuItem(
        label: 'Tsa Sione',
        icon: Icons.library_music_outlined,
        color: const Color(0xFFBD10E0),
        onTap: () {},
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) => _buildMenuTile(context, menuItems[index], isDark),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, _MenuItem item, bool isDark) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withOpacity(isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.color.withOpacity(isDark ? 0.2 : 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
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

class DailyMannaButton extends StatelessWidget {
  const DailyMannaButton({super.key});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://dailymanna.app');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _launchUrl,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFE57373), // Coral/Red
                Color(0xFF81C784), // Soft Green
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.coffee_outlined,
                      color: Color(0xFF66BB6A),
                      size: 30,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 30),
                child: Center(
                  child: Row(
                    children: [
                      Text(
                        'Daily Manna',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
