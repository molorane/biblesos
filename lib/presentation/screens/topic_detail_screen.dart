import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/core/utils/content_parser.dart';

class TopicDetailScreen extends ConsumerWidget {
  final Topic topic;
  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topicContentAsync = ref.watch(topicContentProvider(topic.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                topic.text,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/11.jpg', // Use a nice background image
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scriptural Guidance',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          topicContentAsync.when(
            data: (contentList) {
              if (contentList.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No content found for this topic.')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final content = contentList[index];
                    final blocks = ContentParser.parse(content.text);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: blocks.map((block) => _buildContentBlock(context, block, isDark)).toList(),
                      ),
                    );
                  },
                  childCount: contentList.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildContentBlock(BuildContext context, ContentBlock block, bool isDark) {
    final theme = Theme.of(context);
    
    switch (block.type) {
      case ContentType.heading:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            block.text,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        );
      case ContentType.subHeading:
        return Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
          child: Text(
            block.text,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
        );
      case ContentType.bibleReference:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories, size: 14, color: theme.primaryColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  block.text,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      case ContentType.verseText:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Text(
            block.text,
            style: GoogleFonts.crimsonText(
              fontSize: 19,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
            ),
          ),
        );
      case ContentType.quote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                width: 4,
              ),
            ),
          ),
          child: Text(
            block.text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            block.text,
            style: GoogleFonts.inter(
              fontSize: 17,
              height: 1.6,
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
            ),
          ),
        );
    }
  }
}
