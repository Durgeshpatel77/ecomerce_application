import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskdetailCustom extends StatelessWidget {
  final String title;
  final String subtitle; // This could be status
  final String description;
  final String deadline;
  final String priority;
  final String workType;
  final String repetition;

  const TaskdetailCustom({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.workType,
    required this.repetition,
  });

  // Generate a soft gradient with pastel tones
  LinearGradient getRandomGradient() {
    final random = Random();
    final List<Color> colors = [
      Color.fromARGB(255, 255, 234, 214),
      Color.fromARGB(255, 232, 243, 255),
      Color.fromARGB(255, 255, 240, 245),
      Color.fromARGB(255, 230, 255, 247),
      Color.fromARGB(255, 250, 230, 255),
      Color.fromARGB(255, 240, 255, 240),
    ];

    Color startColor = colors[random.nextInt(colors.length)];
    Color endColor = colors[random.nextInt(colors.length)];

    return LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final LinearGradient gradient = getRandomGradient();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 3),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0), // reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title.capitalizeFirst ?? '',
                    style: const TextStyle(
                      fontSize: 16, // reduced from 18
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // reduced from 6
              Row(
                children: [
                  const Icon(Icons.info, color: Colors.blueGrey, size: 18), // reduced icon size
                  const SizedBox(width: 4), // reduced from 6
                  Text(
                    subtitle.capitalizeFirst ?? '',
                    style: const TextStyle(
                      fontSize: 14, // reduced from 15
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 14, // increased slightly from 1 for better visual separation
                children: [
                  _buildInfoChip(Icons.calendar_today, "Deadline: ${deadline.capitalizeFirst ?? ''}"),
                  _buildInfoChip(Icons.flag, priority.capitalizeFirst ?? ''),
                  _buildInfoChip(Icons.work, "Type: ${workType.capitalizeFirst ?? ''}"),
                  _buildInfoChip(Icons.repeat, "Repetition: ${repetition.capitalizeFirst ?? ''}"),
                ],
              ),

              Text(
                description.capitalizeFirst ?? '',
                style: const TextStyle(
                  fontSize: 13, // reduced from 14
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4), // add small spacing before chips
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white.withOpacity(0.8),
      avatar: Icon(icon, size: 16, color: Colors.black87),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }
}
