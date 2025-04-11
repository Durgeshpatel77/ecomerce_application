import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../All_custom_widgets/TaskList_Custom.dart';
import '../Controller/TaskList_Controller.dart';

class TasklistPage extends StatelessWidget {
  const TasklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController());
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: controller.statusTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Task List",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 1,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xfffceabb), Color(0xfff8b500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: height * 0.015),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double tabFontSize = constraints.maxWidth * 0.040;
                    final double countFontSize = constraints.maxWidth * 0.04;

                    return Obx(() {
                      final selectedIndex = controller.tabController.index;

                      return TabBar(
                        controller: controller.tabController,
                        isScrollable: false,
                        dividerColor: Colors.transparent,
                        labelPadding: EdgeInsets.symmetric(horizontal: width * 0.02),
                        labelColor: Colors.white,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00c6ff), Color(0xFF0072ff)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        tabs: List.generate(controller.statusTabs.length, (index) {
                          final status = controller.statusTabs[index];
                          final label = status.replaceAll('_', ' ').capitalizeFirst!;
                          final count = controller.taskList.where((t) => t['status'] == status).length;
                          final isSelected = selectedIndex == index;

                          return Tab(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? width * 0.05 : width * 0.02,
                                vertical: height * 0.005,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: tabFontSize,
                                        fontWeight: FontWeight.w600,
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

                    if (filtered.isEmpty) {
                      return const Center(child: Text("No tasks found"));
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];

                        return GestureDetector(
                          onTap: () {
                            Get.toNamed('/TaskDetailPage', arguments: task);
                          },
                          child: TasklistCustom(
                            taskname: task['title']?.toString() ?? 'No Title',
                            status: task['status']?.toString() ?? 'Unknown',
                            description: task['work_detail']?.toString() ?? 'No Description',
                            deadline: task['deadline']?.toString() ?? '',
                            priority: task['priority']?.toString() ?? '',
                          // workType: task['work_type']?.toString() ?? '',
                          // repetition: task['repetition']?.toString() ?? '',
                            taskId: task['id']?.toString() ?? '',
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
