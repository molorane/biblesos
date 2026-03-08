import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Provider for selected language ('en' or 'or')
class ConvertsLanguageNotifier extends Notifier<String> {
  @override
  String build() => 'en';

  void set(String language) => state = language;
}

final convertsLanguageProvider = NotifierProvider<ConvertsLanguageNotifier, String>(
  ConvertsLanguageNotifier.new,
);

class ConvertsScreen extends ConsumerWidget {
  const ConvertsScreen({super.key});

  Map<int, String> _getSeriesData(String language) {
    if (language == 'or') {
      return {
        0: "TATAISO EA SEHAPI SA MOEA",
        1: "KHOLISEHO EA PHOLOHO",
        2: "THAPELO",
        3: "BIBELE LE OENA",
        4: "MOLEKO",
        5: "TLHORISO",
        6: "HO TIISETSA TUMELONG",
        7: "LELAPA LA NNETE",
        8: "BOLELLA METSOALLE EA HAO",
      };
    }
    return {
      0: "Guides to convert series",
      1: "Assurance of salvation",
      2: "Prayer",
      3: "Bible and you",
      4: "Temptation",
      5: "Persecution",
      6: "Steadfastness",
      7: "True Family",
      8: "Tell your friends",
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(convertsLanguageProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final seriesData = _getSeriesData(language);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          language == 'en' ? 'Converts' : 'Basalali',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _LanguageToggle(
                  label: 'EN',
                  isSelected: language == 'en',
                  onTap: () => ref.read(convertsLanguageProvider.notifier).set('en'),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _LanguageToggle(
                  label: 'OR',
                  isSelected: language == 'or',
                  onTap: () => ref.read(convertsLanguageProvider.notifier).set('or'),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: seriesData.length,
        itemBuilder: (context, index) {
          final title = seriesData[index]!;
          return _SeriesTile(
            index: index,
            title: title,
            language: language,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _LanguageToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4DB66A) : (isDark ? Colors.white10 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SeriesTile extends StatelessWidget {
  final int index;
  final String title;
  final String language;
  final bool isDark;

  const _SeriesTile({
    required this.index,
    required this.title,
    required this.language,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeriesDetailScreen(
                index: index,
                title: title,
                language: language,
              ),
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
                    '${index + 1}',
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
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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

class SeriesDetailScreen extends StatelessWidget {
  final int index;
  final String title;
  final String language;

  const SeriesDetailScreen({
    super.key,
    required this.index,
    required this.title,
    required this.language,
  });

  Future<String> _loadContent() async {
    try {
      return await rootBundle.loadString('assets/converts/$language/$index.txt');
    } catch (e) {
      return 'Error loading content: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<String>(
        future: _loadContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4DB66A)));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load content'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.crimsonText(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4DB66A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB66A).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  snapshot.data!,
                  style: GoogleFonts.crimsonText(
                    fontSize: 19,
                    height: 1.6,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
