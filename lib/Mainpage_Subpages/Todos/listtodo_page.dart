import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../All_custom_widgets/Ttodolist_Custom.dart';

import '../../Controller/Todos controller/Ttodostatus_controller.dart';
import '../../Controller/Todos controller/ttodo_controller.dart';
import 'AddTodo_page.dart';
import 'detailtodo_page.dart';

class ListTodoPage extends StatelessWidget {
  ListTodoPage({super.key});
  final TodoController todoController = Get.put(TodoController());
  final statusController = Get.find<TodoStatusController>();

  final RxBool _initialized = false.obs;

  @override
  Widget build(BuildContext context) {
    if (!_initialized.value) {
      todoController.fetchTodos();
      statusController.fetchStatuses();
      _initialized.value = true;
    }

    final double height = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Todo List",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 1,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Obx(() {
              final status = todoController.statusCount;
              return Container(
                height: 60,
                margin: EdgeInsets.symmetric(
                  vertical: height * 0.015,
                  horizontal: height * 0.020,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    topLeft: Radius.circular(8),
                  ),
                  border: Border.all(color: Colors.black38, width: 1),
                ),
                child: TabBar(
                  isScrollable: false,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.blue,
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
                  children:
                      [
                        'pending',
                        'in_progress',
                        'completed',
                        'cancelled',
                      ].map<Widget>((status) {
                        final filtered =
                            todoController.todoList
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
                                onTap: () async {
                                  Get.dialog(
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    barrierDismissible: false,
                                  );

                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                  Get.back();

                                  Get.to(
                                    () => TodoDetailPage(
                                      id: item['id'].toString(),
                                      todo: item,
                                      notes: List<Map<String, dynamic>>.from(
                                        item['notes'],
                                      ),
                                    ),
                                  );
                                },
                                child: TodoItemWidget(
                                  title: item,
                                  status: item['status'] ?? '',
                                  deadline: item['due_date'] ?? '',
                                  onStatusTap: () {
                                    showStatusBottomSheet(context, item);
                                  },
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
        floatingActionButton: Container(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () {
              Get.to(() => AddtodoPage());
            },
            child: const Icon(Icons.add, color: Colors.black, size: 28),
          ),
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${count ?? 0}",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showStatusBottomSheet(BuildContext context, Map<String, dynamic> todo) {
    final String currentStatus = todo['status'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return Obx(
              () => Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Update Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Divider(),
                ...statusController.statusList.map((status) {
                  final bool isCurrent = currentStatus == status['value'];
                  return Column(
                    children: [
                      ListTile(
                        tileColor: isCurrent ? Colors.green.withOpacity(0.1) : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        leading: isCurrent
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                        title: Text(
                          status['label'],
                          style: TextStyle(
                            color: isCurrent ? Colors.green : Colors.black,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onTap: () async {
                          if (!isCurrent) {
                            statusController.selectedStatus.value = status;
                            Navigator.pop(context); // Close sheet
                            await statusController.updateTodoStatus(todo['uuid']);
                            await todoController.fetchTodos();
                          } else {
                            Navigator.pop(context); // Close without update
                          }
                        },
                      ),
                      const Divider(height: 1),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
