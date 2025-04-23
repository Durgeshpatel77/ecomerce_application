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
      appBar: AppBar(
        title: const Text(
          "Add Todo",
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffceabb), Color(0xfff8b500)],
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(
                child: Column(
                  children: [
                    _buildTextField("Title", controller.titleController, maxLines: 1),
                    const SizedBox(height: 12),
                    _buildTextField("Description", controller.descriptionController, maxLines: 5),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDateTimeField(
                context: context,
                selectedDateTime: controller.selectedDateTime,
                onTap: () => controller.selectDateTime(context),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Obx(
                      () => DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Priority"),
                    value: controller.selectedPriority.value.isEmpty
                        ? null
                        : controller.selectedPriority.value,
                    onChanged: (value) => controller.selectedPriority.value = value ?? '',
                    items: controller.priorityOptions
                        .map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Obx(
                      () => DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Status"),
                    value: controller.selectedStatus.value.isEmpty
                        ? null
                        : controller.selectedStatus.value,
                    onChanged: (value) => controller.selectedStatus.value = value ?? '',
                    items: controller.statusOptions
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Obx(
                      () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Attachment",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: controller.pickAttachment,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, color: Colors.deepPurple),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  controller.selectedAttachmentPath.value.isEmpty
                                      ? "No file selected"
                                      : controller.selectedAttachmentPath.value.split('/').last,
                                  style: const TextStyle(color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: controller.submitTodo,
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label),
    );
  }

  Widget _buildDateTimeField({
    required BuildContext context,
    required Rx<DateTime?> selectedDateTime,
    required VoidCallback onTap,
    String label = "Due Date & Time",
  }) {
    return _buildCard(
      child: Obx(() {
        final dateTime = selectedDateTime.value;
        return GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextField(
              readOnly: true,
              controller: TextEditingController(
                text: dateTime != null
                    ? DateFormat("yyyy-MM-dd hh:mm a").format(dateTime)
                    : "",
              ),
              decoration: _inputDecoration(label).copyWith(
                suffixIcon: const Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
