import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../All_custom_widgets/TaskList_Custom.dart';
import '../../Controller/TaskList_Controller.dart';

class TasklistPage extends StatelessWidget {
  const TasklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController());
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    // Fetching tasks after the widget has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.taskList.isEmpty && !controller.isLoading.value) {
        controller.fetchTasks();
      }
    });

    return DefaultTabController(
      length: controller.statusTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Task List",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.taskList.isEmpty) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.fetchTasks();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),
                        backgroundColor: Colors.blue, // Button color
                      ),
                      child: const Icon(Icons.refresh, size: 32, color: Colors.white),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Tab bar with dynamic status filtering
                    Container(
                      height: 60,
                      margin: EdgeInsets.symmetric(
                        vertical: height * 0.015,
                        horizontal: height * 0.020,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadiusDirectional.only(
                          topEnd: Radius.circular(8),
                          topStart: Radius.circular(8),
                        ),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double tabFontSize = constraints.maxWidth * 0.055;
                          final double countFontSize = constraints.maxWidth * 0.07;

                          return Obx(() {
                            return TabBar(
                              controller: controller.tabController,
                              isScrollable: false,
                              indicatorColor: Colors.blue,
                              dividerColor: Colors.transparent,
                              labelPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.02,
                              ),
                              labelColor: Colors.blue,
                              tabs: List.generate(controller.statusTabs.length, (index) {
                                final status = controller.statusTabs[index];
                                final label = status.replaceAll('_', ' ').capitalizeFirst!;
                                final count = controller.taskList
                                    .where((t) => t['status'] == status)
                                    .length;

                                return Tab(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.02,
                                      vertical: height * 0.005,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: tabFontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: height * 0.004),
                                          Text(
                                            "$count",
                                            style: TextStyle(
                                              fontSize: countFontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: controller.tabController,
                        children: controller.statusTabs.map((status) {
                          final filtered = controller.taskList
                              .where((task) => task['status'] == status)
                              .toList();

                          return RefreshIndicator(
                            onRefresh: controller.fetchTasks,
                            child: filtered.isEmpty
                                ? const Center(child: Text("No tasks found"))
                                : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final task = filtered[index];
                                return GestureDetector(
                                  onTap: () {
                                    Get.toNamed(
                                      '/TaskDetailPage',
                                      arguments: task,
                                    );
                                  },
                                  child: TasklistCustom(
                                    taskname: task['title']?.toString() ?? 'No Title',
                                    status: task['status']?.toString() ?? 'Unknown',
                                    deadline: task['deadline']?.toString() ?? '',
                                    taskId: task['id']?.toString() ?? '',
                                    assignedTo: task['assign_to']?['name']?.toString() ?? '', // <-- update this line
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
