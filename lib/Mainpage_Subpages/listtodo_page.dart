import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../All_custom_widgets/Ttodolist_Custom.dart';
import '../Controller/Ttodostatus_controller.dart';
import '../Controller/ttodo_controller.dart';

class ListTodoPage extends StatelessWidget {
  ListTodoPage({super.key});
  final TodoController todoController = Get.put(TodoController());
  final TodoStatusController statusController = Get.put(TodoStatusController());

  @override
  Widget build(BuildContext context) {
    todoController.fetchTodos();
    statusController.fetchStatuses();

    final double height = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Todo List", style: TextStyle(fontWeight: FontWeight.bold)),
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
        body: Column(
          children: [
            Obx(() {
              final status = todoController.statusCount;
              return Container(
                margin: EdgeInsets.symmetric(vertical: height * 0.015),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: TabBar(
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00c6ff), Color(0xFF0072ff)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    _buildTab("Pending", status['pending']),
                    _buildTab("In Progress", status['in_progress']),
                    _buildTab("Completed", status['completed']),
                    _buildTab("Cancelled", status['cancelled']),
                  ],
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (todoController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  children: [
                    'pending',
                    'in_progress',
                    'completed',
                    'cancelled',
                  ].map<Widget>((status) {
                    final filtered = todoController.todoList
                        .where((item) => item['status'] == status)
                        .toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text('No todos found.'));
                    }

                    return RefreshIndicator(
                      onRefresh: todoController.fetchTodos,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];

                          return GestureDetector(
                            onTap: () {},
                            child: TodoItemWidget(
                              title: item,
                              status: item['status'] ?? '',
                              priority: item['priority'] ?? '',
                              deadline: item['due_date'] ?? '',
                              description: item['description'] ?? '',
                              onStatusTap: () {
                                _showStatusDialog(context, item);
                              },
                              item: item,
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int? count) {
    return Tab(
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${count ?? 0}",
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, Map<String, dynamic> todo) {
    final RxString selectedStatus = RxString(todo['status'] ?? '');
    final currentStatus = todo['status'];

    Get.dialog(
      AlertDialog(
        title: const Text("Change Todo Status"),
        content: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: statusController.statusList.map((status) {
              final isSelected = selectedStatus.value == status['value'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: GestureDetector(
                  onTap: () {
                    selectedStatus.value = status['value'];
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                        if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          // Wrap ElevatedButton in a Container
          Container(
            height: 40,
            width: 80,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            InkWell(
              onTap: () async {
                if (selectedStatus.value != currentStatus) {
                  // Set the selected status in the controller
                  statusController.selectedStatus.value = statusController.statusList.firstWhere(
                        (status) => status['value'] == selectedStatus.value,
                    orElse: () => {},
                  );
                  // Call the update method
                  await statusController.updateTodoStatus(todo['uuid']);
                }
                Navigator.pop(context);
              },

              child: Center(child: const Text("Save")),
            ),
          )
        ],
      ),
      barrierDismissible: false,
    );
  }
}
