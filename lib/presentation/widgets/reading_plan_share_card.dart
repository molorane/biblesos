import 'package:flutter/material.dart';
import 'package:biblesos/domain/entities/reading_plan_models.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadingPlanShareCard extends StatelessWidget {
  final ReadingPlan plan;
  final int totalRead;
  final int totalChapters;
  final EfficiencyInfo efficiency;

  const ReadingPlanShareCard({
    super.key,
    required this.plan,
    required this.totalRead,
    required this.totalChapters,
    required this.efficiency,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalChapters > 0 ? totalRead / totalChapters : 0.0;
    final endDate = plan.startDate.add(Duration(days: plan.durationDays));

    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1A1A), Colors.grey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BIBLE SOS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4DB66A),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Reading Journey',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Image.asset('assets/logo.png', height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.auto_stories, color: Colors.white, size: 30)),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            plan.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: efficiency.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: efficiency.color.withOpacity(0.5)),
            ),
            child: Text(
              efficiency.description.toUpperCase(),
              style: GoogleFonts.outfit(
                color: efficiency.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROGRESS',
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4DB66A),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalRead / $totalChapters',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Chapters Completed',
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              color: const Color(0xFF4DB66A),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              _buildInfoItem('STARTED', DateFormat('MMM dd, yyyy').format(plan.startDate)),
              const SizedBox(width: 40),
              _buildInfoItem('EST. FINISH', DateFormat('MMM dd, yyyy').format(endDate)),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              '"Thy word is a lamp unto my feet, and a light unto my path."',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 8, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
