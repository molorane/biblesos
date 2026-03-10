import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum HymnPartType { stanza, chorus }

class HymnPart {
  final String text;
  final HymnPartType type;
  final int? number;

  HymnPart({
    required this.text,
    required this.type,
    this.number,
  });
}

class PremiumHymnViewer extends StatelessWidget {
  final String id;
  final String title;
  final String? author;
  final String? hymnKey;
  final List<HymnPart> content;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Color themeColor;

  const PremiumHymnViewer({
    super.key,
    required this.id,
    required this.title,
    this.author,
    this.hymnKey,
    required this.content,
    this.onNext,
    this.onPrevious,
    this.themeColor = const Color(0xFF4DB66A),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Region
                Center(
                  child: Column(
                    children: [
                      Text(
                        id,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (author != null && author!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          author!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      ],
                      if (hymnKey != null && hymnKey!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            children: [
                              const TextSpan(text: 'Major Key: '),
                              TextSpan(
                                text: hymnKey,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
                    ],
                  ),
                ),

                // Content Region
                ...content.map((part) => _buildPart(part, isDark, theme)),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        
        // Navigation Bottom Bar
        _buildBottomNav(isDark, theme),
      ],
    );
  }

  Widget _buildPart(HymnPart part, bool isDark, ThemeData theme) {
    if (part.type == HymnPartType.chorus) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.music_note, size: 16, color: themeColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chorus',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(isDark ? 0.05 : 0.08),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      border: Border(
                        left: BorderSide(color: themeColor, width: 4),
                      ),
                    ),
                    child: Text(
                      part.text,
                      style: GoogleFonts.crimsonText(
                        fontSize: 20,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (part.number != null)
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 4, right: 16),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    part.number.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(width: 44),
            Expanded(
              child: Text(
                part.text,
                style: GoogleFonts.crimsonText(
                  fontSize: 20,
                  height: 1.5,
                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBottomNav(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            icon: Icons.chevron_left,
            label: 'Previous',
            onTap: onPrevious,
            themeColor: themeColor,
            isDark: isDark,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Hymn $id',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right,
            label: 'Next',
            onTap: onNext,
            themeColor: themeColor,
            isDark: isDark,
            isRight: true,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color themeColor;
  final bool isDark;
  final bool isRight;

  const _NavButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.themeColor,
    required this.isDark,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) Icon(icon, color: onTap != null ? themeColor : Colors.grey),
            if (!isRight) const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onTap != null ? (isDark ? Colors.white70 : Colors.black87) : Colors.grey,
              ),
            ),
            if (isRight) const SizedBox(width: 4),
            if (isRight) Icon(icon, color: onTap != null ? themeColor : Colors.grey),
          ],
        ),
      ),
    );
  }
}
