import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TodoItemWidget extends StatelessWidget {
  final Map<String, dynamic> title;
  final String status;
  final String priority;
  final String deadline;
  final String description;
  final VoidCallback onStatusTap;
  final Map<String, dynamic> item;
  final List<dynamic>? attachments; // Add attachments parameter

  const TodoItemWidget({
    Key? key,
    required this.title,
    required this.status,
    required this.priority,
    required this.deadline,
    required this.description,
    required this.onStatusTap,
    required this.item,
    this.attachments, // Initialize the attachments parameter
  }) : super(key: key);

  // Function to launch URLs
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Print the attachments list
    print('Attachments: $attachments');  // Add this line for debugging

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
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
                  GestureDetector(
                    onTap: onStatusTap,
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
              // If attachments are provided, display them
              if (attachments != null && attachments!.isNotEmpty)
                _buildAttachments(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the attachments UI
  Widget _buildAttachments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attachments!.map((attachment) {
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.attach_file, size: 16, color: Colors.black87),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (attachment is String && Uri.parse(attachment).isAbsolute) {
                    _launchURL(attachment);
                  } else {
                    // Handle non-URL attachments (e.g., file paths or other formats)
                  }
                },
                child: Text(
                  attachment.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

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
