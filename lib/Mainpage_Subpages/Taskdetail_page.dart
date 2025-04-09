import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../All_custom_widgets/TaskDetail_Custom.dart';
import '../Controller/Task_Controller.dart';

class TaskdetailPage extends StatelessWidget {
  const TaskdetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Task Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurpleAccent, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body:
      Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.taskList.isEmpty) {
          return const Center(child: Text("No tasks found"));
        }

        return ListView.builder(
          itemCount: controller.taskList.length,
          itemBuilder: (context, index) {
            final task = controller.taskList[index];
            return TaskdetailCustom(
              title: task['title'] ?? '',
              subtitle: task['status'] ?? '',
              description: 'Deadline: ${task['deadline'] ?? 'N/A'}',
            );
          },
        );
      }),
    );
  }
}
