import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biblesos/core/utils/content_parser.dart';
import 'package:biblesos/presentation/widgets/premium_content_renderer.dart';
import 'package:biblesos/core/utils/doctrine_utils.dart';

class DoctrinesScreen extends StatelessWidget {
  const DoctrinesScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Bible Doctrines',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: DoctrineUtils.doctrineTitles.length + 1, // +1 for Introduction
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildIntroCard(context, isDark);
          }
          final doctrineIndex = index;
          final title = DoctrineUtils.doctrineTitles[index - 1];
          return _DoctrineTile(
            index: doctrineIndex,
            title: title,
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, top: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DoctrineDetailScreen(
                index: 0,
                title: "Introduction",
                isIntro: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [Colors.blue.shade900.withOpacity(0.5), Colors.blue.shade800.withOpacity(0.3)]
                  : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Introduction',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Understand the foundation of our faith',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctrineTile extends StatelessWidget {
  final int index;
  final String title;
  final bool isDark;

  const _DoctrineTile({
    required this.index,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctrineDetailScreen(
                index: index,
                title: title,
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
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctrineDetailScreen extends StatefulWidget {
  final int index;
  final String title;
  final bool isIntro;

  const DoctrineDetailScreen({
    super.key,
    required this.index,
    required this.title,
    this.isIntro = false,
  });

  @override
  State<DoctrineDetailScreen> createState() => _DoctrineDetailScreenState();
}

class _DoctrineDetailScreenState extends State<DoctrineDetailScreen> {
  bool _isFullVersion = false;
  late Future<String> _contentFuture;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() {
    final type = (widget.isIntro || _isFullVersion) ? 'full' : 'compact';
    _contentFuture = rootBundle.loadString('assets/doctrines/en/$type/${widget.index}.txt');
  }

  void _toggleVersion() {
    setState(() {
      _isFullVersion = !_isFullVersion;
      _loadContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        actions: [
          if (!widget.isIntro)
            TextButton.icon(
              onPressed: _toggleVersion,
              icon: Icon(
                _isFullVersion ? Icons.unfold_less : Icons.unfold_more,
                size: 18,
                color: const Color(0xFF4A90E2),
              ),
              label: Text(
                _isFullVersion ? 'Compact' : 'View Full',
                style: const TextStyle(
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load doctrine'));
          }

          final blocks = ContentParser.parse(snapshot.data ?? '');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isFullVersion && !widget.isIntro) ...[
                  Text(
                    'Compact Version',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A90E2).withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                PremiumContentRenderer.renderBlocks(blocks, isDark),
                const SizedBox(height: 40),
                if (!_isFullVersion && !widget.isIntro)
                  Center(
                    child: OutlinedButton(
                      onPressed: _toggleVersion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Read Full Detailed Doctrine'),
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
