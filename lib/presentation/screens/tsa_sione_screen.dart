import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biblesos/presentation/widgets/premium_hymn_viewer.dart'
    as viewer;
import 'package:biblesos/core/utils/hymn_utils.dart';
import 'package:biblesos/core/utils/responsive_utils.dart';

// View modes: Grid or List
enum HymnViewMode { grid, list }

class HymnViewModeNotifier extends Notifier<HymnViewMode> {
  @override
  HymnViewMode build() => HymnViewMode.grid;
  void set(HymnViewMode mode) => state = mode;
}

final hymnViewModeProvider =
    NotifierProvider<HymnViewModeNotifier, HymnViewMode>(
      HymnViewModeNotifier.new,
    );

class HymnSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final hymnSearchQueryProvider =
    NotifierProvider<HymnSearchQueryNotifier, String>(
      HymnSearchQueryNotifier.new,
    );

class TsaSioneScreen extends ConsumerStatefulWidget {
  const TsaSioneScreen({super.key});


  @override
  ConsumerState<TsaSioneScreen> createState() => _TsaSioneScreenState();
}

class _TsaSioneScreenState extends ConsumerState<TsaSioneScreen> {
  @override
  void initState() {
    super.initState();
    // Reset search query when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hymnSearchQueryProvider.notifier).set('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hymns = HymnUtils.getHymns();
    final searchQuery = ref.watch(hymnSearchQueryProvider);
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    // Filter hymns based on search query
    final filteredHymns = hymns.entries.where((entry) {
      final query = searchQuery.toLowerCase();
      return entry.key.contains(query) ||
          entry.value.toLowerCase().contains(query);
    }).toList();

    // Sort filtered hymns numerically
    filteredHymns.sort((a, b) {
      final aNum = int.tryParse(a.key) ?? 0;
      final bNum = int.tryParse(b.key) ?? 0;
      return aNum.compareTo(bNum);
    });

    final viewMode = ref.watch(hymnViewModeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tsa Sione',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: Icon(
              viewMode == HymnViewMode.grid ? Icons.list : Icons.grid_view,
            ),
            onPressed: () {
              ref
                  .read(hymnViewModeProvider.notifier)
                  .set(
                    viewMode == HymnViewMode.grid
                        ? HymnViewMode.list
                        : HymnViewMode.grid,
                  );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 16),
            child: TextField(
              onChanged: (value) =>
                  ref.read(hymnSearchQueryProvider.notifier).set(value),
              decoration: InputDecoration(
                hintText: 'Search by number or title...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: viewMode == HymnViewMode.grid
                ? GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveUtils.getCrossAxisCount(context, phone: 4, tablet: 6, desktop: 8),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredHymns.length,
                    itemBuilder: (context, index) {
                      final hymn = filteredHymns[index];
                      return _buildHymnGridTile(
                        context,
                        hymn.key,
                        hymn.value,
                        isDark,
                      );
                    },
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    itemCount: filteredHymns.length,
                    itemBuilder: (context, index) {
                      final hymn = filteredHymns[index];
                      return _buildHymnListTile(
                        context,
                        hymn.key,
                        hymn.value,
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHymnGridTile(
    BuildContext context,
    String number,
    String title,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _openHymnDetail(context, number, title),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHymnListTile(
    BuildContext context,
    String number,
    String title,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () => _openHymnDetail(context, number, title),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFBD10E0).withOpacity(0.1),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFFBD10E0),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 18,
          color: isDark ? Colors.white30 : Colors.black26,
        ),
      ),
    );
  }

  void _openHymnDetail(BuildContext context, String number, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HymnDetailScreen(number: number, title: title),
      ),
    );
  }
}

class HymnDetailScreen extends ConsumerWidget {
  final String number;
  final String title;

  const HymnDetailScreen({
    super.key,
    required this.number,
    required this.title,
  });

  Future<List<viewer.HymnPart>> _parseHymnContent(String rawContent) async {
    final lines = rawContent.split('\n');
    final content = <viewer.HymnPart>[];

    String currentStanza = '';
    int? currentNumber;

    // Skip the first line as it's the header
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        if (currentStanza.isNotEmpty) {
          content.add(
            viewer.HymnPart(
              text: currentStanza.trim(),
              type: viewer.HymnPartType.stanza,
              number: currentNumber,
            ),
          );
          currentStanza = '';
          currentNumber = null;
        }
        continue;
      }

      // Check if line starts with a number (stanza number)
      final match = RegExp(r'^(\d+)\s+(.*)').firstMatch(line);
      if (match != null) {
        if (currentStanza.isNotEmpty) {
          content.add(
            viewer.HymnPart(
              text: currentStanza.trim(),
              type: viewer.HymnPartType.stanza,
              number: currentNumber,
            ),
          );
        }
        currentNumber = int.tryParse(match.group(1)!);
        currentStanza = '${match.group(2)!}\n';
      } else {
        currentStanza += '$line\n';
      }
    }

    if (currentStanza.isNotEmpty) {
      content.add(
        viewer.HymnPart(
          text: currentStanza.trim(),
          type: viewer.HymnPartType.stanza,
          number: currentNumber,
        ),
      );
    }

    return content;
  }

  Future<String> _loadRawContent() async {
    return await rootBundle.loadString('assets/tsa-sione/$number.txt');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hymns = HymnUtils.getHymns();

    // Split title and author
    final titleParts = title.split(' - ');
    final mainTitle = titleParts[0];
    final author = titleParts.length > 1 ? titleParts[1] : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hymn $number',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<String>(
        future: _loadRawContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFBD10E0)),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load hymn content'));
          }

          return FutureBuilder<List<viewer.HymnPart>>(
            future: _parseHymnContent(snapshot.data!),
            builder: (context, contentSnapshot) {
              if (contentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFBD10E0)),
                );
              }

              final sortedKeys = hymns.keys.toList()
                ..sort((a, b) {
                  final aN =
                      int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                  final bN =
                      int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                  return aN.compareTo(bN);
                });
              final currentIndex = sortedKeys.indexOf(number);

              return viewer.PremiumHymnViewer(
                id: number,
                title: mainTitle,
                author: author,
                content: contentSnapshot.data ?? [],
                themeColor: const Color(0xFFBD10E0),
                onNext: currentIndex < sortedKeys.length - 1
                    ? () {
                        final nextKey = sortedKeys[currentIndex + 1];
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HymnDetailScreen(
                              number: nextKey,
                              title: hymns[nextKey]!,
                            ),
                          ),
                        );
                      }
                    : null,
                onPrevious: currentIndex > 0
                    ? () {
                        final prevKey = sortedKeys[currentIndex - 1];
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HymnDetailScreen(
                              number: prevKey,
                              title: hymns[prevKey]!,
                            ),
                          ),
                        );
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
