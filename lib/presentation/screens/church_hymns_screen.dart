import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xml/xml.dart';
import 'package:biblesos/presentation/widgets/premium_hymn_viewer.dart' as viewer;

// Hymn Model
class ChurchHymn {
  final String id;
  final String title;
  final List<HymnPart> content;

  ChurchHymn({
    required this.id,
    required this.title,
    required this.content,
  });
}

enum HymnPartType { stanza, chorus }

class HymnPart {
  final String text;
  final HymnPartType type;
  final int? number;

  HymnPart(this.text, this.type, [this.number]);
}

// View modes: Grid or List
enum ChurchHymnViewMode { grid, list }

// State Management
class ChurchHymnViewModeNotifier extends Notifier<ChurchHymnViewMode> {
  @override
  ChurchHymnViewMode build() => ChurchHymnViewMode.grid;
  void set(ChurchHymnViewMode mode) => state = mode;
}

final churchHymnViewModeProvider = NotifierProvider<ChurchHymnViewModeNotifier, ChurchHymnViewMode>(
  ChurchHymnViewModeNotifier.new,
);

class ChurchHymnLanguageNotifier extends Notifier<String> {
  @override
  String build() => 'English';
  void set(String lang) => state = lang;
}

final churchHymnLanguageProvider = NotifierProvider<ChurchHymnLanguageNotifier, String>(
  ChurchHymnLanguageNotifier.new,
);

class ChurchHymnSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final churchHymnSearchProvider = NotifierProvider<ChurchHymnSearchNotifier, String>(
  ChurchHymnSearchNotifier.new,
);

// Async Loader for Hymns
final churchHymnsProvider = FutureProvider<List<ChurchHymn>>((ref) async {
  final language = ref.watch(churchHymnLanguageProvider);
  final xmlString = await rootBundle.loadString('assets/hymns/$language.xml');
  final document = XmlDocument.parse(xmlString);
  final hymnElements = document.findAllElements('Hymn');

  return hymnElements.map((element) {
    final id = element.findElements('id').first.innerText.trim();
    final title = element.findElements('title').first.innerText.trim();
    final content = <HymnPart>[];

    int stanzaCount = 0;
    for (var node in element.children) {
      if (node is XmlElement) {
        if (node.name.local == 'stanza') {
          stanzaCount++;
          content.add(HymnPart(node.innerText.trim(), HymnPartType.stanza, stanzaCount));
        } else if (node.name.local == 'chorus') {
          content.add(HymnPart(node.innerText.trim(), HymnPartType.chorus));
        }
      }
    }

    return ChurchHymn(id: id, title: title, content: content);
  }).toList();
});

class ChurchHymnsScreen extends ConsumerStatefulWidget {
  const ChurchHymnsScreen({super.key});

  @override
  ConsumerState<ChurchHymnsScreen> createState() => _ChurchHymnsScreenState();
}

class _ChurchHymnsScreenState extends ConsumerState<ChurchHymnsScreen> {
  final List<String> languages = const ['English', 'Sesotho', 'French', 'Hausa', 'Yoruba'];

  @override
  void initState() {
    super.initState();
    // Reset search query when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(churchHymnSearchProvider.notifier).set('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(churchHymnViewModeProvider);
    final selectedLang = ref.watch(churchHymnLanguageProvider);
    final searchQuery = ref.watch(churchHymnSearchProvider);
    final hymnsAsync = ref.watch(churchHymnsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hymns',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: Icon(
              viewMode == ChurchHymnViewMode.grid ? Icons.list_alt : Icons.grid_view_outlined,
            ),
            onPressed: () {
              ref.read(churchHymnViewModeProvider.notifier).set(
                    viewMode == ChurchHymnViewMode.grid ? ChurchHymnViewMode.list : ChurchHymnViewMode.grid,
                  );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Language Switcher
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                final isSelected = lang == selectedLang;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(lang),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(churchHymnLanguageProvider.notifier).set(lang);
                      }
                    },
                    selectedColor: const Color(0xFF4DB66A).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF4DB66A),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF4DB66A) : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                );
              },
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (value) => ref.read(churchHymnSearchProvider.notifier).set(value),
                decoration: InputDecoration(
                  hintText: 'Search hymns...',
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white24 : Colors.black26),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: hymnsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4DB66A))),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (hymns) {
                final filteredHymns = hymns.where((h) {
                  final query = searchQuery.toLowerCase();
                  return h.id.contains(query) || h.title.toLowerCase().contains(query);
                }).toList();

                if (viewMode == ChurchHymnViewMode.grid) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: filteredHymns.length,
                    itemBuilder: (context, index) {
                      final hymn = filteredHymns[index];
                      return _GridHymnItem(hymn: hymn, isDark: isDark);
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHymns.length,
                    itemBuilder: (context, index) {
                      final hymn = filteredHymns[index];
                      return _ListHymnItem(hymn: hymn, isDark: isDark);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GridHymnItem extends StatelessWidget {
  final ChurchHymn hymn;
  final bool isDark;

  const _GridHymnItem({required this.hymn, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HymnReaderScreen(hymnId: hymn.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: Text(
            hymn.id,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF4DB66A),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListHymnItem extends StatelessWidget {
  final ChurchHymn hymn;
  final bool isDark;

  const _ListHymnItem({required this.hymn, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HymnReaderScreen(hymnId: hymn.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB66A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    hymn.id,
                    style: const TextStyle(
                      color: Color(0xFF4DB66A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  hymn.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HymnReaderScreen extends ConsumerWidget {
  final String hymnId;

  const HymnReaderScreen({super.key, required this.hymnId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hymnsAsync = ref.watch(churchHymnsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hymn $hymnId',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: hymnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4DB66A))),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (hymns) {
          final index = hymns.indexWhere((h) => h.id == hymnId);
          if (index == -1) return const Center(child: Text('Hymn not found'));
          
          final hymn = hymns[index];
          
          return viewer.PremiumHymnViewer(
            id: hymn.id,
            title: hymn.title,
            content: hymn.content.map((p) => viewer.HymnPart(
              text: p.text,
              type: p.type == HymnPartType.stanza 
                  ? viewer.HymnPartType.stanza 
                  : viewer.HymnPartType.chorus,
              number: p.number,
            )).toList(),
            onNext: index < hymns.length - 1 
                ? () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HymnReaderScreen(hymnId: hymns[index + 1].id),
                      ),
                    )
                : null,
            onPrevious: index > 0 
                ? () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HymnReaderScreen(hymnId: hymns[index - 1].id),
                      ),
                    )
                : null,
          );
        },
      ),
    );
  }
}
