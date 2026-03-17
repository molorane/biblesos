import 'package:flutter/material.dart';

class BibleCoverThumbnail extends StatelessWidget {
  final String abbreviation;
  final Color color;

  const BibleCoverThumbnail({
    super.key,
    required this.abbreviation,
    this.color = const Color(0xFF6D4C41),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Simulated spine
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  abbreviation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 20,
                  height: 1,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.menu_book,
                  color: Colors.white70,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
