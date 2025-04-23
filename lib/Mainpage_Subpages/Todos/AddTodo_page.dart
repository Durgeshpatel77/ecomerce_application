import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Controller/add_todo_controller.dart';

class AddtodoPage extends StatelessWidget {
  final AddTodoController controller = Get.put(AddTodoController());

  AddtodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Todo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller.titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 10),
              Obx(() {
                final dateTime = controller.selectedDateTime.value;
                return ListTile(
                  title: Text(
                    dateTime != null
                        ? DateFormat("yyyy-MM-dd hh:mm a").format(dateTime)
                        : "Select Due Date & Time",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => controller.selectDateTime(context),
                );
              }),
              const SizedBox(height: 10),
              Obx(() => DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedPriority.value.isEmpty
                    ? null
                    : controller.selectedPriority.value,
                hint: const Text("Select Priority"),
                onChanged: (value) =>
                controller.selectedPriority.value = value ?? '',
                items: controller.priorityOptions
                    .map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                ))
                    .toList(),
              )),
              const SizedBox(height: 10),
              Obx(() => DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedStatus.value.isEmpty
                    ? null
                    : controller.selectedStatus.value,
                hint: const Text("Select Status"),
                onChanged: (value) =>
                controller.selectedStatus.value = value ?? '',
                items: controller.statusOptions
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
              )),
              const SizedBox(height: 20),
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Attachment",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: controller.pickAttachment,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file,
                              color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.selectedAttachmentPath.value
                                  .isEmpty
                                  ? "No file selected"
                                  : controller.selectedAttachmentPath.value
                                  .split('/')
                                  .last,
                              style:
                              const TextStyle(color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: controller.submitTodo,
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
