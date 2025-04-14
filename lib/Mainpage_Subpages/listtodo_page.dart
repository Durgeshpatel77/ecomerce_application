import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../All_custom_widgets/Ttodolist_Custom.dart';
import '../Controller/ttodo_controller.dart';

class ListTodoPage extends StatelessWidget {
  ListTodoPage({super.key});

  final TodoController todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    todoController.fetchTodos();
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

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

                              return TodoItemWidget(
                                item: item,
                                status: item['status'] ?? '',
                                priority: item['priority'] ?? '',
                                deadline: item['due_date'] ?? '',
                                description:
                                    item['description'] ??
                                    '', // Passing status here
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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
}
