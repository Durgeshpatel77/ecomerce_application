import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Controller/Todos controller/add_todo_controller.dart';

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
          decoration:  BoxDecoration(
            color: Colors.white
          ),
        ),
      ),
      body: Container(

        padding: const EdgeInsets.only(top: 15,left: 25,right: 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(
                child: Column(
                  children: [
                    _buildTextField1("Title", controller.titleController, maxLines: 1),
                    const SizedBox(height: 12),
                    _buildTextField("Description", controller.descriptionController, maxLines: 5),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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

              const SizedBox(height: 10),
              _buildDateTimeField(
                context: context,
                selectedDateTime: controller.selectedDateTime,
                onTap: () => controller.selectDateTime(context),
              ),

              const SizedBox(height: 10),
              _buildCard(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                 //   const Text("Attachment", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: controller.pickAttachment,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.attach_file, color: Colors.deepPurple),
                            SizedBox(width: 10),
                            Text("Select Files", style: TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...controller.selectedAttachmentPaths.map((path) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              path.split('/').last,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                )),

              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
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
                  SizedBox(width: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed:(){
                      Get.back();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

  Widget _buildCard({required Widget child}) {
    return child;
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
    //  borderRadius: BorderRadius.circular(12),
    ),
  );
  Widget _buildTextField1(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      maxLength: 15,
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label).copyWith(
        counterText: '', // Hide the counter
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      //maxLength: 15,
      controller: controller,
      maxLines: maxLines,
        decoration: _inputDecoration(label).copyWith(
      counterText: '', // Hide the counter
    ),
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