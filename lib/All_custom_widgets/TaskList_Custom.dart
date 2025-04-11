import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/TaskDetail_controller.dart';
import '../Controller/TaskList_Controller.dart';
import '../Mainpage_Subpages/Taskdetail_page.dart';

class TasklistCustom extends StatelessWidget {
  final String taskId; // <-- Add this line
  final String taskname;
  final String status; // status
  final String description;
  final String deadline;
  final String priority;
  //final String workType;
  //final String repetition;

  const TasklistCustom({
    super.key,
    required this.taskId, // <-- Add this line
    required this.taskname,
    required this.status,
    required this.description,
    required this.deadline,
    required this.priority,
    //required this.workType,
    //required this.repetition,
  });

  LinearGradient getRandomGradient() {
    final random = Random();
    final List<Color> colors = [
      const Color.fromARGB(255, 255, 234, 214),
      const Color.fromARGB(255, 232, 243, 255),
      const Color.fromARGB(255, 255, 240, 245),
      const Color.fromARGB(255, 230, 255, 247),
      const Color.fromARGB(255, 250, 230, 255),
      const Color.fromARGB(255, 240, 255, 240),
    ];

    Color startColor = colors[random.nextInt(colors.length)];
    Color endColor = colors[random.nextInt(colors.length)];

    return LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final date = "${dateTime.day.toString().padLeft(2, '0')} "
          "${_monthName(dateTime.month)} ${dateTime.year}";
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final period = dateTime.hour >= 12 ? "PM" : "AM";
      final time = "${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period";
      return "$date, $time";
    } catch (_) {
      return isoString ?? '';
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final LinearGradient gradient = getRandomGradient();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final taskController = Get.find<TaskController>();
            final result = await taskController.getTaskDetailById(taskId); // returns Map with task + imageUrls
            final fullDetails = result['task'];
            final imageUrls = result['imageUrls'];

            Navigator.pop(context); // dismiss loading

            print("Full Task Details: $fullDetails");

            Get.to(() => TaskDetailPage(
              taskname: fullDetails['title'] ?? '',
              status: fullDetails['status'] ?? '',
              description: fullDetails['work_detail'] ?? '',
              deadline: fullDetails['deadline'] ?? '',
              priority: fullDetails['priority'] ?? '',
              workType: fullDetails['work_type'] ?? '',
              repetition: fullDetails['repetition'] ?? '',
              repeatUntil: fullDetails['repeat_until'] ?? '',
              createdBy: (fullDetails['created_user'] is Map) ? (fullDetails['created_user']['name'] ?? '') : '',
              assignedTo: (fullDetails['assign_to'] is Map) ? (fullDetails['assign_to']['name'] ?? '') : '',
              departmentName: (fullDetails['department_object'] is Map) ? (fullDetails['department_object']['department_name'] ?? '') : '',
              subdepartments: (fullDetails['sub_departments_names'] ?? '').toString(),
              taskImages: imageUrls, // already parsed and fixed URLs
              notes: List<Map<String, dynamic>>.from(fullDetails['notes'] ?? []),
              createdAt: _formatDateTime(fullDetails['created_at']),
              updatedAt: _formatDateTime(fullDetails['updated_at']),
            ));
          } catch (e) {
            Navigator.pop(context); // close loader
            Get.snackbar('Error', 'Failed to load task details');
            print('Error loading task: $e');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      taskname.capitalizeFirst ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    _buildInfoChip(
                      null,
                      status.replaceAll('_', ' ').capitalizeFirst ?? '',
                    ),
                  ],
                ),
                Wrap(
                  spacing: 14,
                  children: [
                    _buildInfoChip(
                      Icons.calendar_today,
                      "Deadline: ${deadline.capitalizeFirst ?? ''}",
                    ),
                    _buildInfoChip(Icons.flag, priority.capitalizeFirst ?? ''),
                    // _buildInfoChip(
                    //   Icons.work,
                    //   "Type: ${workType.capitalizeFirst ?? ''}",
                    // ),
                    // _buildInfoChip(
                    //   Icons.repeat,
                    //   "Repetition: ${repetition.capitalizeFirst ?? ''}",
                    // ),
                  ],
                ),
                Text(
                  description.capitalizeFirst ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData? icon, String label) {
    return Chip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white.withOpacity(0.8),
      avatar: icon != null ? Icon(icon, size: 16, color: Colors.black87) : null,
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }
}
