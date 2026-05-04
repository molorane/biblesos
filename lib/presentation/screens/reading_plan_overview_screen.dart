import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/reading_plan_providers.dart';
import 'package:biblesos/presentation/screens/reading_plan_creation_screen.dart';
import 'package:biblesos/presentation/screens/reader_screen.dart';
import 'package:biblesos/domain/entities/reading_plan_models.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:biblesos/presentation/widgets/reading_plan_share_card.dart';

class ReadingPlanOverviewScreen extends ConsumerWidget {
  const ReadingPlanOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(allReadingPlansProvider);
    final coverageAsync = ref.watch(bibleCoverageProvider);
    final streakAsync = ref.watch(streakProvider);
    final upcomingAsync = ref.watch(upcomingChaptersProvider);
    final heatmapAsync = ref.watch(heatmapProvider);
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
              ref.invalidate(heatmapProvider);
              ref.invalidate(streakProvider);
              ref.invalidate(upcomingChaptersProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(child: _buildStreakBadge(context, streakAsync)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCoverageMiniCard(context, coverageAsync)),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildUpNextSection(context, upcomingAsync),
                ),
                SliverToBoxAdapter(
                  child: _buildHeatmapSection(context, heatmapAsync),
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
                      child: Text('My Active Plans', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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

  Widget _buildStreakBadge(BuildContext context, AsyncValue<int> streakAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: streakAsync.when(
        data: (streak) => Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streak', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                const Text('Day Streak', style: TextStyle(fontSize: 10, color: Colors.orange)),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => const Icon(Icons.error_outline, color: Colors.orange),
      ),
    );
  }

  Widget _buildCoverageMiniCard(BuildContext context, AsyncValue<double> coverageAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4DB66A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4DB66A).withOpacity(0.2)),
      ),
      child: coverageAsync.when(
        data: (coverage) => Row(
          children: [
            const Icon(Icons.auto_stories, color: Color(0xFF4DB66A), size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${coverage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4DB66A))),
                const Text('Coverage', style: TextStyle(fontSize: 10, color: Color(0xFF4DB66A))),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => const Icon(Icons.error_outline),
      ),
    );
  }

  Widget _buildUpNextSection(BuildContext context, AsyncValue<List<ReadingPlanChapter>> upcomingAsync) {
    final theme = Theme.of(context);
    return upcomingAsync.when(
      data: (chapters) {
        if (chapters.isEmpty) return const SizedBox();
        final first = chapters.first;
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF4DB66A).withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('UP NEXT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4DB66A), letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${first.bookName} ${first.chapter}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('~4 mins of reading', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReaderScreen(bookId: first.bookId, chapter: first.chapter),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DB66A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('READ NOW'),
                  ),
                ],
              ),
              if (chapters.length > 1) ...[
                const Divider(height: 24),
                Text('Also today: ${chapters.skip(1).map((c) => "${c.bookName} ${c.chapter}").join(", ")}', 
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildHeatmapSection(BuildContext context, AsyncValue<List<DateTime>> heatmapAsync) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('READING ACTIVITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              Text('Last 3 months', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 16),
          heatmapAsync.when(
            data: (dates) => _buildHeatmapGrid(dates),
            loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
            error: (_, __) => const Text('Error loading activity'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(List<DateTime> readDates) {
    // Show last 14 weeks (98 days)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 97)); // 14 weeks * 7 - 1
    
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            itemCount: 98,
            itemBuilder: (context, index) {
              final date = startDate.add(Duration(days: index));
              final hasRead = readDates.contains(date);
              final isFuture = date.isAfter(today);
              
              return Container(
                decoration: BoxDecoration(
                  color: isFuture 
                      ? Colors.transparent 
                      : (hasRead ? const Color(0xFF4DB66A) : Colors.grey.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Less', style: TextStyle(fontSize: 8, color: Colors.grey)),
            const SizedBox(width: 4),
            _buildHeatBox(0.1),
            _buildHeatBox(1.0),
            const SizedBox(width: 4),
            const Text('More', style: TextStyle(fontSize: 8, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildHeatBox(double opacity) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF4DB66A).withOpacity(opacity),
        borderRadius: BorderRadius.circular(1),
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
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('${efficiency.estimatedTimeMinutes} mins left', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const Spacer(),
                  Icon(Icons.info_outline, size: 14, color: efficiency.color),
                  const SizedBox(width: 6),
                  Text(efficiency.description, style: TextStyle(fontSize: 11, color: efficiency.color, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
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
              } else if (value == 'recalculate') {
                _showRecalculateConfirm(context, ref, plan.id);
              } else if (value == 'share_image') {
                _shareProgressImage(context, plan, progressList);
              } else if (value == 'share') {
                _shareProgress(plan, progressList);
              } else if (value == 'delete') {
                ReadingPlanOverviewScreen()._showDeleteConfirm(context, ref, plan.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 12), Text('Edit Plan')])),
              const PopupMenuItem(value: 'recalculate', child: Row(children: [Icon(Icons.refresh, size: 18), SizedBox(width: 12), Text('Recalculate (Grace)')])),
              const PopupMenuItem(value: 'share_image', child: Row(children: [Icon(Icons.image, size: 18), SizedBox(width: 12), Text('Share Progress Card')])),
              const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share, size: 18), SizedBox(width: 12), Text('Share Progress Text')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 12), Text('Delete Plan', style: TextStyle(color: Colors.red))])),
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
  void _showRecalculateConfirm(BuildContext context, WidgetRef ref, int planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need some Grace?'),
        content: const Text('This will spread your remaining unread chapters across the rest of your plan days, starting from today. Great for catching up!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4DB66A), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(readingPlanControllerProvider.notifier).recalculatePlan(planId);
              if (context.mounted) {
                Navigator.pop(context); // Close detail screen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan recalculated! You got this!')));
              }
            },
            child: const Text('RECALCULATE'),
          ),
        ],
      ),
    );
  }

  void _shareProgress(ReadingPlan plan, List<Map<String, dynamic>> progress) {
    final completed = progress.where((d) => d['read_chapters'] == d['total_chapters']).length;
    final percent = progress.isEmpty ? 0 : (completed / progress.length * 100).toInt();
    
    final text = '''
📖 My Bible Reading Progress

Plan: ${plan.title}
Status: $percent% Completed ($completed/${progress.length} Days)

"I have hidden your word in my heart that I might not sin against you." - Psalm 119:11

Shared from Bible SOS App
''';
    Share.share(text);
  }

  void _shareProgressImage(BuildContext context, ReadingPlan plan, List<Map<String, dynamic>> progressList) async {
    final screenshotController = ScreenshotController();
    
    final totalRead = progressList.fold<int>(0, (sum, d) => sum + (d['read_chapters'] as int));
    final totalChapters = progressList.fold<int>(0, (sum, d) => sum + (d['total_chapters'] as int));
    final efficiency = EfficiencyInfo.calculate(totalChapters, totalRead, plan.startDate, plan.durationDays);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF4DB66A))),
    );

    try {
      final image = await screenshotController.captureFromWidget(
        ReadingPlanShareCard(
          plan: plan,
          totalRead: totalRead,
          totalChapters: totalChapters,
          efficiency: efficiency,
        ),
        delay: const Duration(milliseconds: 100),
      );

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/reading_plan_share.png').create();
      await file.writeAsBytes(image);

      if (context.mounted) Navigator.pop(context); // Close loading

      await Share.shareXFiles([XFile(file.path)], text: 'My Bible Reading Progress via Bible SOS');
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate image: $e')));
      }
    }
  }
}
