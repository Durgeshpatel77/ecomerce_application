import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TodoItemWidget extends StatelessWidget {
  final Map<String, dynamic> title;
  final String status;
  final String priority;
  final String deadline;
  final String description;
  final VoidCallback onStatusTap;
  final Map<String, dynamic> item;
  final List<dynamic>? attachments;

  const TodoItemWidget({
    Key? key,
    required this.title,
    required this.status,
    required this.priority,
    required this.deadline,
    required this.description,
    required this.onStatusTap,
    required this.item,
    this.attachments,
  }) : super(key: key);

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  String formatDate(String deadline) {
    DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(deadline);
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }

  Color _getStatusColor1(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow.shade100;
      case 'in_progress':
        return Colors.lightBlue.shade100; // Red for 'delayed'
      case 'completed':
        return Colors.green.shade100; // Green for 'done'
      case 'cancelled':
        return Colors.red.shade100;
      default:

        return Colors.red; // Default color for unknown status
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(8),topLeft: Radius.circular(8)),
          border: Border.all(width: 1,color: Colors.black26),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onStatusTap,
                    child: _buildInfoChip1(
                      null,
                      status.replaceAll('_', ' ').capitalizeFirst ?? '',
                      _getStatusColor1(status),
                    ),
                  ),
                  SizedBox(width: 5,),
                    ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 14,
                children: [
                  _buildInfoChip1(
                    Icons.calendar_today,
                    "Deadline: ${formatDate(deadline)}",  // Now it shows only the date
                    Colors.white,
                    forceWhiteBackground: true,
                  ),
                  _buildInfoChip1(
                    Icons.flag,
                    priority.capitalizeFirst ?? '',
                    Colors.white,
                    forceWhiteBackground: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                (description.isEmpty)
                    ? "No description Found"
                    : description.capitalizeFirst ?? '',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (attachments != null && attachments!.isNotEmpty)
                _buildAttachments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          attachments!.map((attachment) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_file,
                    size: 16,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (attachment is String &&
                          Uri.parse(attachment).isAbsolute) {
                        _launchURL(attachment);
                      }
                    },
                    child: Text(
                      attachment.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildInfoChip1(IconData? icon, String label, Color statusColor, {bool forceWhiteBackground = false}) {
    return Chip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: forceWhiteBackground ? Colors.white : statusColor, // <-- New logic
      avatar: icon != null ? Icon(icon, size: 16, color: Colors.black) : null,
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    );
  }
}
