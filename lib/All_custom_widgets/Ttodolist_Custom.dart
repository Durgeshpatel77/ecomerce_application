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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  String formatDate(String deadline) {
    DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(deadline);
    return DateFormat("dd/MM/yyyy").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10,bottom: 16,left: 16,right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: onStatusTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Text(
                            status.replaceAll('_', ' ',).capitalizeFirst ?? '',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          SizedBox(width: 10,),
                          Icon(Icons.keyboard_arrow_down,color: Colors.white,)
                        ],
                      ),
                    ),
                  ),
                   SizedBox(width: 5),
                   Icon(Icons.more_vert, color: Colors.black),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    " ${formatDate(deadline)}",
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      priority.capitalizeFirst ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
