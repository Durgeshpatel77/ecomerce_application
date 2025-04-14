import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/ttodo_controller.dart';

class ListtodoPage extends StatelessWidget {
  ListtodoPage({super.key});

  final TodoController todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    // Fetch todos when this page is loaded
    todoController.fetchTodos();

    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: Obx(() {
        if (todoController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (todoController.todoList.isEmpty) {
          return const Center(child: Text('No todos found.'));
        }

        return ListView.builder(
          itemCount: todoController.todoList.length,
          itemBuilder: (context, index) {
            final item = todoController.todoList[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? 'No Title',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text("Description: ${item['description'] ?? 'N/A'}"),
                    Text("Due Date: ${item['due_date'] ?? 'N/A'}"),
                    Text("Priority: ${item['priority'] ?? 'N/A'}"),
                    Text("Status: ${item['status'] ?? 'N/A'}"),
                    Text("Assigned By (User ID): ${item['assigned_by'] ?? 'N/A'}"),
                    Text("UUID: ${item['uuid'] ?? 'N/A'}"),
                    Text("Created At: ${item['created_at'] ?? 'N/A'}"),
                    Text("Updated At: ${item['updated_at'] ?? 'N/A'}"),
                    if (item['notes'] != null && item['notes'].isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          const Text(
                            "Notes:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...List.generate(item['notes'].length, (noteIndex) {
                            final note = item['notes'][noteIndex];
                            return Text("- ${note.toString()}");
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
