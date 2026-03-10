import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biblesos/core/utils/content_parser.dart';

class PremiumContentRenderer extends StatelessWidget {
  final ContentBlock block;
  final bool isDark;

  const PremiumContentRenderer({
    super.key,
    required this.block,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
      case ContentType.listItem:
        final children = ContentParser.parse(block.text);
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 12.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: children.map((child) {
                    if (child.type == ContentType.text) {
                      return Text(
                        child.text,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          height: 1.5,
                          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                        ),
                      );
                    }
                    return PremiumContentRenderer(block: child, isDark: isDark);
                  }).toList(),
                ),
              ),
            ],
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
      case ContentType.boldRed:
        return Text(
          block.text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.red.shade400 : Colors.red.shade700,
            height: 1.5,
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
