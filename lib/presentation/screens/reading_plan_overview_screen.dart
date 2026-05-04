import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/reading_plan_providers.dart';
import 'package:biblesos/presentation/screens/reading_plan_creation_screen.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';
import 'package:biblesos/domain/entities/reading_plan_models.dart';
import 'package:intl/intl.dart';

class ReadingPlanOverviewScreen extends ConsumerWidget {
  const ReadingPlanOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(allReadingPlansProvider);
    final coverageAsync = ref.watch(bibleCoverageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Reading Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReadingPlanCreationScreen()),
            ),
          ),
        ],
      ),
      body: plansAsync.when(
        data: (plans) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allReadingPlansProvider);
              ref.invalidate(bibleCoverageProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildCoverageCard(context, coverageAsync),
                ),
                if (plans.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildNoPlanView(context),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text('My Plans', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final plan = plans[index];
                        return _buildPlanCard(context, ref, plan);
                      },
                      childCount: plans.length,
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildCoverageCard(BuildContext context, AsyncValue<double> coverageAsync) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4DB66A), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4DB66A).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Bible Coverage', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              const Icon(Icons.auto_stories, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          coverageAsync.when(
            data: (coverage) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${coverage.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 8),
                      child: Text('Completed', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: coverage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text('You have read ${(coverage * 11.89).toInt()} of 1189 chapters', 
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: Colors.white))),
            error: (_, __) => const Text('Error loading coverage', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, Map<String, dynamic> planMap) {
    final theme = Theme.of(context);
    final plan = ReadingPlan.fromMap(planMap);
    final totalRead = planMap['read_chapters'] as int;
    final totalChapters = planMap['total_chapters'] as int;
    final progress = (totalChapters > 0) ? (totalRead / totalChapters) : 0.0;
    
    // Duration from providers or map
    // We need the duration_days which isn't in the base ReadingPlan model yet but is in the creation logic.
    // Actually, I should probably add duration_days to the table if it's not there.
    // Wait, let's check the table schema in database_service.dart again.
    
    // Ah, it's NOT in the table. I should probably calculate it from the days count.
    final durationDays = (planMap['progress_list'] as List).length;
    
    final efficiency = EfficiencyInfo.calculate(
      totalChapters, 
      totalRead, 
      plan.startDate, 
      durationDays > 0 ? durationDays : 365
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: () => _showPlanDetails(context, ref, planMap),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${DateFormat('MMM dd, yyyy').format(plan.startDate)} • $durationDays Days', 
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildEfficiencyBadge(efficiency),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$totalRead / $totalChapters Chapters', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4DB66A))),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: theme.dividerColor.withOpacity(0.1),
                  color: const Color(0xFF4DB66A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: efficiency.color),
                  const SizedBox(width: 6),
                  Text(efficiency.description, style: TextStyle(fontSize: 11, color: efficiency.color, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEfficiencyBadge(EfficiencyInfo efficiency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: efficiency.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: efficiency.color.withOpacity(0.3)),
      ),
      child: Text(
        '${efficiency.percentage.toInt()}% Paced',
        style: TextStyle(color: efficiency.color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showPlanDetails(BuildContext context, WidgetRef ref, Map<String, dynamic> planMap) {
    // Navigate to a detail view or just show the grid
    // For now, let's just update the "activePlan" to this one so the existing grid works
    // Actually, it's better to show a dedicated detail screen or a dialog.
    // I'll show the existing grid in a full-screen dialog for now.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPlanDetailScreen(planMap: planMap),
      ),
    ).then((_) {
      ref.invalidate(allReadingPlansProvider);
      ref.invalidate(bibleCoverageProvider);
    });
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
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final totalRead = progress.fold<int>(0, (sum, d) => sum + (d['read_chapters'] as int));
                      final totalChapters = progress.fold<int>(0, (sum, d) => sum + (d['total_chapters'] as int));
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$totalRead / $totalChapters Chapters Read', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color?.withOpacity(0.7))),
                        ],
                      );
                    },
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

  Widget _buildDaysGrid(BuildContext context, List<Map<String, dynamic>> progress, {int? planId}) {
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
          onTap: () => _showDayDetails(context, day, planId: planId),
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

  void _showDayDetails(BuildContext context, Map<String, dynamic> day, {int? planId}) {
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
                                    planId: planId,
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
        content: const Text('This will permanently remove this reading plan and all its progress. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              ref.read(readingPlanControllerProvider.notifier).deletePlan(planId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan deleted')));
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ReadingPlanDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> planMap;
  const ReadingPlanDetailScreen({super.key, required this.planMap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ReadingPlan.fromMap(planMap);
    final progressList = planMap['progress_list'] as List<Map<String, dynamic>>;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingPlanCreationScreen(existingPlan: plan),
                  ),
                );
              } else if (value == 'delete') {
                ReadingPlanOverviewScreen()._showDeleteConfirm(context, ref, plan.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Plan')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Plan', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          ReadingPlanOverviewScreen()._buildPlanHeader(context, plan, AsyncValue.data(progressList)),
          Expanded(
            child: ReadingPlanOverviewScreen()._buildDaysGrid(context, progressList, planId: plan.id),
          ),
        ],
      ),
    );
  }
}
