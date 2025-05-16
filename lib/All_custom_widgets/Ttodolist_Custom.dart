import 'package:ecomerce_application/Mainpage_Subpages/Todos/detailtodo_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Controller/Todos controller/ttodo_controller.dart';


class TodoItemWidget extends StatelessWidget {
  final Map<String, dynamic> title;
  final String status;
  final String deadline;
  final VoidCallback onStatusTap;

   TodoItemWidget({
    Key? key,
    required this.title,
    required this.status,
    required this.deadline,
    required this.onStatusTap,

  }) : super(key: key);
  final TodoController todoController = Get.put(TodoController());

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  String formatDate(String deadline) {
    try {
      DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm a").parse(deadline);
      return DateFormat("dd/MM/yyyy hh:mm a").format(dateTime);
    } catch (e) {
      return deadline; // fallback if parsing fails
    }
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
                 //  SizedBox(width: 5),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.only(left: 20),
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onSelected: (value) {
                      final todoId = title['id']?.toString() ?? '';

                      if (value == 'view') {
                        Get.to(() => TodoDetailPage(
                          id: todoId,
                          todo: title,
                          notes: (title['notes'] as List?)?.cast<Map<String, dynamic>>() ?? [],
                        ));
                      } else if (value == 'edit') {
                        // TODO: Implement edit logic
                      }
                      else if (value == 'delete') {
                        Get.defaultDialog(
                          title: 'Delete Todo',
                          titleStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                          middleText: 'Are you sure you want to delete this todo?',
                          middleTextStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          backgroundColor: Colors.white,
                          radius: 15,
                          barrierDismissible: false,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

                          // Use custom cancel button with reduced border radius
                          cancel: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // less rounded
                              ),
                              side: BorderSide(color: Colors.grey.shade700),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                            ),
                          ),

                          // Use custom confirm button with reduced border radius
                          confirm: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              Get.find<TodoController>().deleteTodo(todoId);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // less rounded
                              ),
                              backgroundColor: Colors.red.shade600,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.black54),
                            SizedBox(width: 8),
                            Text('View Detail'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.black54),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete',style: TextStyle(color: Colors.red),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    "${formatDate(deadline)}",
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "By ${title['created_user']?['name'] ?? 'Unknown'}",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
