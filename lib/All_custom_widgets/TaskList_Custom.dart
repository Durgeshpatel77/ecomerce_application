import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/Taskstatus_contoller.dart';
import '../Controller/TaskList_Controller.dart';
import '../Mainpage_Subpages/Tasks/Taskdetail_page.dart';

class TasklistCustom extends StatelessWidget {
  final String taskId;
  final String taskname;
  final String status;
  final String deadline;
  final String assignedTo;

  TasklistCustom({
    super.key,
    required this.taskId,
    required this.taskname,
    required this.status,
    required this.deadline,
    required this.assignedTo,
  });

  final TaskStatusController statusController = Get.find<TaskStatusController>();
  final RxMap<String, String> selectedStatusPerTask = <String, String>{}.obs;

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      return "$day/$month/$year";
    } catch (_) {
      return isoString;
    }
  }

  String _formatStatusLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'work_not_start':
      case 'work not start':
        return 'Not Started';
      case 'in_progress':
      case 'in progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return raw.replaceAll('_', ' ').capitalizeFirst ?? raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusController.statusList.isEmpty) {
      statusController.fetchStatuses();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
              createdBy: (fullDetails['created_user'] is Map)
                  ? (fullDetails['created_user']['name'] ?? '')
                  : '',
              assignedTo: (fullDetails['assign_to'] is Map)
                  ? (fullDetails['assign_to']['name'] ?? '')
                  : '',
              departmentName: (fullDetails['department_object'] is Map)
                  ? (fullDetails['department_object']['department_name'] ?? '')
                  : '',
              taskImages: imageUrls,
              notes: List<Map<String, dynamic>>.from(fullDetails['notes'] ?? []),
              createdAt: (fullDetails['created_at']),
              updatedAt: _formatDateTime(fullDetails['updated_at']),
              todo: null,
            ));
          } catch (e) {
            Navigator.pop(context);
            Get.snackbar(
              'Error',
              'Failed to load task details',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          padding: const EdgeInsets.only(top: 10,bottom: 16,left: 16,right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      taskname.capitalizeFirst ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Obx(() {
                    final currentStatus = selectedStatusPerTask[taskId] ?? status;
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            backgroundColor: Colors.white,
                            builder: (_) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 15,),
                                    const Text(
                                      'Update Status',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 15,),
                                    Divider(),
                                    ...statusController.statusList.map((s) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(_formatStatusLabel(s['label'])),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              if (s['value'] == currentStatus) return;

                                              selectedStatusPerTask[taskId] = s['value'];

                                              try {
                                                final taskController = Get.find<TaskController>();
                                                final detail = await taskController.getTaskDetailById(taskId);
                                                final uuid = detail['task']['uuid'];

                                                statusController.selectedStatus.value =
                                                    statusController.statusList.firstWhere(
                                                          (x) => x['value'] == s['value'],
                                                      orElse: () => {},
                                                    );
                                                await statusController.updateTaskStatus(uuid, s['value']);
                                                statusController.updateTaskStatusInUI(uuid, s['value']);
                                                await taskController.fetchTasks();
                                              } catch (_) {}
                                            },
                                          ),
                                          const Divider(height: 1), // Adds a divider between items
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal:2, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 10,),
                              Text(
                                _formatStatusLabel(currentStatus),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.white),
                            ],
                          ),
                        ),
                      );
                  }),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_vert, color: Colors.black),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    "${_formatDateTime(deadline)}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        Text(
                          "By ${assignedTo.capitalizeFirst ?? ''}",
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
