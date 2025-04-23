import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTodoController extends GetxController {
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var selectedDateTime = Rxn<DateTime>();
  var selectedPriority = "".obs;
  var selectedStatus = "".obs;
  var selectedAttachmentPath = "".obs;

  List<String> priorityOptions = ['Low', 'Medium', 'High'];
  List<String> statusOptions = ['Pending', 'In Progress', 'Completed'];

  void selectDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime.value ?? DateTime.now()),
      );
      if (pickedTime != null) {
        selectedDateTime.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  Future<void> pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      selectedAttachmentPath.value = result.files.single.path!;
    } else {
      Get.snackbar("No file", "Attachment selection canceled",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void submitTodo() {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedDateTime.value == null ||
        selectedPriority.value.isEmpty ||
        selectedStatus.value.isEmpty) {
      Get.snackbar("Error", "Please fill all fields",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final todoData = {
      "title": titleController.text,
      "description": descriptionController.text,
      "due_date":
      DateFormat("yyyy-MM-dd hh:mm a").format(selectedDateTime.value!),
      "priority": selectedPriority.value,
      "status": selectedStatus.value,
      "attachment": selectedAttachmentPath.value.isNotEmpty
          ? selectedAttachmentPath.value
          : null,
    };

    print("Submitted Todo: $todoData");
    Get.snackbar("Success", "Todo submitted",
        snackPosition: SnackPosition.BOTTOM);
  }
}
