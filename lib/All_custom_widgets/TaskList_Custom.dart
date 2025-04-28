import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/Taskstatus_contoller.dart';
import '../Controller/TaskList_Controller.dart';
import '../Mainpage_Subpages/Tasks/Taskdetail_page.dart';

class TasklistCustom extends StatelessWidget {
  final String taskId;
  final String taskname;
  final String status;
  final String description;
  final String deadline;
  final String priority;

  const TasklistCustom({
    super.key,
    required this.taskId,
    required this.taskname,
    required this.status,
    required this.description,
    required this.deadline,
    required this.priority,
  });

  // Helper function to map status to color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return Colors.green; // Green for 'done'
      case 'delayed':
        return Colors.red; // Red for 'delayed'
      case 'in_progress':
        return Colors.orange;
        // Orange for 'in progress'
      case 'not_started':
        return Colors.blue;
      default:

    return Colors.grey; // Default color for unknown status
    }
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final taskController = Get.find<TaskController>();
            final result = await taskController.getTaskDetailById(taskId);
            final fullDetails = result['task'];
            final imageUrls = result['imageUrls'];

            Navigator.pop(context);

            Get.to(() => TaskDetailPage(
              taskname: fullDetails['title'] ?? '',
              status: fullDetails['status'] ?? '',
              description: fullDetails['work_detail'] ?? '',
              deadline: fullDetails['deadline'] ?? '',
              priority: fullDetails['priority'] ?? '',
              workType: fullDetails['work_type'] ?? '',
              createdBy: (fullDetails['created_user'] is Map) ? (fullDetails['created_user']['name'] ?? '') : '',
              assignedTo: (fullDetails['assign_to'] is Map) ? (fullDetails['assign_to']['name'] ?? '') : '',
              departmentName: (fullDetails['department_object'] is Map) ? (fullDetails['department_object']['department_name'] ?? '') : '',
              taskImages: imageUrls,
              notes: List<Map<String, dynamic>>.from(fullDetails['notes'] ?? []),
              createdAt: _formatDateTime(fullDetails['created_at']),
              updatedAt: _formatDateTime(fullDetails['updated_at']),
              todo: null,
            ));
          } catch (e) {
            Navigator.pop(context);
            Get.snackbar('Error', 'Failed to load task details');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            border: Border.all(color: Colors.black26, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        taskname.capitalizeFirst ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _showStatusDialog(context, taskId),
                      child: _buildInfoChip(null, status.replaceAll('_', ' ').capitalizeFirst ?? '', _getStatusColor(status)),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 14,
                  children: [
                    _buildInfoChip(Icons.calendar_today, "Deadline: ${deadline.capitalizeFirst ?? ''}", Colors.white),
                    _buildInfoChip(Icons.flag, priority.capitalizeFirst ?? '', Colors.white),
                  ],
                ),
                Text(
                  (description.isEmpty) ? "No description Found" : description.capitalizeFirst ?? '',
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

  Widget _buildInfoChip(IconData? icon, String label, Color statusColor) {
    return Chip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: statusColor, // Direct color with no opacity
      avatar: icon != null ? Icon(icon, size: 16, color: Colors.black) : null, // Only display icon if it's not null
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black), // White text for contrast
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // Adjust padding to center text
    );
  }

  void _showStatusDialog(BuildContext context, String taskId) {
    final statusController = Get.find<TaskStatusController>();
    statusController.fetchStatuses();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Change Task Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Obx(() {
            if (statusController.isLoading.value) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: statusController.statusList.map((status) {
                  final isSelected =
                      statusController.selectedStatus.value?['value'] == status['value'];
                  return InkWell(
                    onTap: () {
                      statusController.selectedStatus.value = status;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            status['label'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.blue : Colors.black87,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.blue),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Obx(() {
              return ElevatedButton(
                onPressed: statusController.selectedStatus.value == null
                    ? null
                    : () async {
                  final newStatus = statusController.selectedStatus.value?['value'];
                  try {
                    final taskController = Get.find<TaskController>();
                    final detail = await taskController.getTaskDetailById(taskId);
                    final correctUuid = detail['task']['uuid'];

                    await statusController.updateTaskStatus(correctUuid);
                    statusController.updateTaskStatusInUI(correctUuid, newStatus);

                    Navigator.pop(context);
                  } catch (e) {
                    Navigator.pop(context);
                    Get.snackbar("Error", "Failed to update status: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save"),
              );
            }),
          ],
        );
      },
    );
  }
}
