import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/screens/topic_detail_screen.dart';
import 'package:biblesos/domain/entities/bible_models.dart';

class AllTopicsScreen extends ConsumerWidget {
  const AllTopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topicsAsync = ref.watch(allTopicsProvider);
    final searchQuery = ref.watch(topicSearchQueryProvider);
    final searchResultsAsync = ref.watch(searchTopicsProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'All Topics',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar (keeping consistency with TopicsScreen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
                  ),
                ),
                child: TextField(
                  onChanged: (value) => ref.read(topicSearchQueryProvider.notifier).set(value),
                  decoration: InputDecoration(
                    hintText: 'Search Topics or Questions',
                    hintStyle: GoogleFonts.inter(
                      color: isDark ? Colors.white54 : Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey.shade500),
                  ),
                ),
              ),
            ),

            // FAQ Card (without SEE ALL or promo card)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FAQ',
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What question borders you?',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  searchQuery.isEmpty
                    ? topicsAsync.when(
                        data: (topics) => Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: topics.map((topic) => _TopicChip(
                            topic: topic,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TopicDetailScreen(topic: topic),
                                ),
                              );
                            },
                          )).toList(),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Text('Error loading topics: $err'),
                      )
                    : searchResultsAsync.when(
                        data: (topics) => topics.isEmpty
                          ? const Text('No results found')
                          : Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              children: topics.map((topic) => _TopicChip(
                                topic: topic,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TopicDetailScreen(topic: topic),
                                    ),
                                  );
                                },
                              )).toList(),
                            ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Text('Error searching: $err'),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;
  const _TopicChip({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.blue.withOpacity(0.15) : const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.1),
          ),
        ),
        child: Text(
          topic.text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.blue.shade200 : const Color(0xFF1976D2),
          ),
        ),
      ),
    );
  }
}
