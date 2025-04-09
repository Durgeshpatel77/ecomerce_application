import 'dart:math';
import 'package:flutter/material.dart';

class TaskdetailCustom extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;

  const TaskdetailCustom({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  // Function to generate a soft random color
  Color getRandomColor() {
    final random = Random();
    int r = 0 + random.nextInt(100); // Soft range 150-250
    int g = 150 + random.nextInt(100);
    int b = 200 + random.nextInt(100);
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    final Color randomColor = getRandomColor();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: randomColor, width: 2),
        ),
        color: randomColor.withOpacity(0.2),
        shadowColor: Colors.black54,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Title: $title",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Status: $subtitle",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
