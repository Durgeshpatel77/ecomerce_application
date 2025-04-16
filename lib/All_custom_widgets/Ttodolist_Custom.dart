import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoItemWidget extends StatelessWidget {
  final Map<String, dynamic> title;
  final String status;
  final String priority;
  final String deadline;
  final String description;
  final VoidCallback onStatusTap; // Add the onStatusTap callback

  const TodoItemWidget({
    Key? key,
    required this.title,
    required this.status,
    required this.priority,
    required this.deadline,
    required this.description,
    required this.onStatusTap, required item, // Initialize the callback
  }) : super(key: key);

  // Function to get a random color from the predefined list
  Color getRandomColor() {
    final colors = [
      const Color.fromARGB(255, 255, 234, 214),
      const Color.fromARGB(255, 232, 243, 255),
      const Color.fromARGB(255, 255, 240, 245),
      const Color.fromARGB(255, 230, 255, 247),
      const Color.fromARGB(255, 250, 230, 255),
      const Color.fromARGB(255, 240, 255, 240),
    ];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final color = getRandomColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.6), color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector( // Wrap status in GestureDetector
                    onTap: onStatusTap,  // Trigger the dialog when status is tapped
                    child: _buildInfoChip1(
                      status.replaceAll('_', ' ').capitalizeFirst ?? '',
                      null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 14,
                children: [
                  _buildInfoChip1("Deadline: $deadline", Icons.calendar_today),
                  _buildInfoChip1(priority.capitalizeFirst ?? '', Icons.flag),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description.length > 50
                    ? "${description.substring(0, 50)}..."
                    : description,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Info Chip Widget accepting both label and optional icon
  Widget _buildInfoChip1(String label, IconData? icon) {
    return Chip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white.withOpacity(0.8),
      avatar: icon != null ? Icon(icon, size: 13, color: Colors.black87) : null,
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      ),
    );
  }
}
