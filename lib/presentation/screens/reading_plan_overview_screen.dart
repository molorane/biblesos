import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/reading_plan_providers.dart';
import 'package:biblesos/presentation/screens/reading_plan_creation_screen.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';
import 'package:intl/intl.dart';

class ReadingPlanOverviewScreen extends ConsumerWidget {
  const ReadingPlanOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlanAsync = ref.watch(activeReadingPlanProvider);
    final progressAsync = ref.watch(readingPlanProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReadingPlanCreationScreen()),
            ),
          ),
          if (activePlanAsync.value != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReadingPlanCreationScreen(existingPlan: activePlanAsync.value),
                    ),
                  );
                } else if (value == 'delete') {
                  _showDeleteConfirm(context, ref, activePlanAsync.value!.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Plan')),
                const PopupMenuItem(value: 'delete', child: Text('Delete Plan', style: TextStyle(color: Colors.red))),
              ],
            ),
        ],
      ),
      body: activePlanAsync.when(
        data: (plan) {
          if (plan == null) {
            return _buildNoPlanView(context);
          }

          return Column(
            children: [
              _buildPlanHeader(context, plan, progressAsync),
              Expanded(
                child: progressAsync.when(
                  data: (progress) => _buildDaysGrid(context, progress),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildNoPlanView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text('No Active Reading Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Start your spiritual journey today!', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DB66A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReadingPlanCreationScreen()),
            ),
            child: const Text('Create My Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(BuildContext context, dynamic plan, AsyncValue<List<Map<String, dynamic>>> progressAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4DB66A).withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Started on ${DateFormat('MMM dd, yyyy').format(plan.startDate)}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.calendar_month, color: Color(0xFF4DB66A), size: 30),
            ],
          ),
          const SizedBox(height: 20),
          progressAsync.when(
            data: (progress) {
              final completed = progress.where((d) => d['read_chapters'] == d['total_chapters']).length;
              final percent = progress.isEmpty ? 0 : (completed / progress.length);
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent.toDouble(),
                      minHeight: 10,
                      backgroundColor: Colors.white,
                      color: const Color(0xFF4DB66A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$completed / ${progress.length} Days Completed', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('${(percent * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox(height: 20),
            error: (_, __) => const SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysGrid(BuildContext context, List<Map<String, dynamic>> progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: progress.length,
      itemBuilder: (context, index) {
        final day = progress[index];
        final total = day['total_chapters'] as int;
        final read = day['read_chapters'] as int;
        final date = DateTime.parse(day['date']);
        final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
        final isToday = DateUtils.isSameDay(date, DateTime.now());

        Color bgColor;
        Color textColor = Colors.white;

        if (read == total && total > 0) {
          bgColor = const Color(0xFF4DB66A); // Green: Completed
        } else if (read > 0) {
          bgColor = Colors.orangeAccent; // Yellow/Orange: Partial
        } else if (isPast) {
          bgColor = Colors.redAccent.withOpacity(0.8); // Red: Missed past day
        } else if (isToday) {
          bgColor = Colors.blueAccent.withOpacity(0.2); // Blue highlight for today
          textColor = Colors.blue.shade900;
        } else {
          bgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100;
          textColor = isDark ? Colors.white70 : Colors.black54;
        }

        return InkWell(
          onTap: () => _showDayDetails(context, day),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
              boxShadow: read > 0 ? [
                BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
              ] : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Day', style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7))),
                Text('${day['day_number']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDayDetails(BuildContext context, Map<String, dynamic> day) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final chaptersAsync = ref.watch(readingPlanChaptersProvider(day['id'] as int));
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Day ${day['day_number']} Readings', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(DateFormat('MMM dd').format(DateTime.parse(day['date'])), style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: chaptersAsync.when(
                    data: (chapters) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = chapters[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              chapter.isRead ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: chapter.isRead ? const Color(0xFF4DB66A) : Colors.grey,
                            ),
                            title: Text('${chapter.bookName} ${chapter.chapter}'),
                            trailing: const Icon(Icons.chevron_right, size: 16),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReaderScreen(
                                    bookId: chapter.bookId,
                                    chapter: chapter.chapter,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, int planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: const Text('This will permanently remove your current reading plan and all its progress. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              ref.read(readingPlanControllerProvider.notifier).deletePlan(planId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan deleted')));
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
