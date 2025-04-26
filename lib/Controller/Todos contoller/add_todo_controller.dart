import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Mainpage_Subpages/Todos/listtodo_page.dart';
import 'ttodo_controller.dart';

class AddTodoController extends GetxController {
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var selectedDateTime = Rxn<DateTime>();
  var selectedPriority = "".obs;
  var selectedStatus = "".obs;
  var selectedAttachmentPaths = <String>[].obs;

  List<String> priorityOptions = ['Low', 'Medium', 'High'];
  List<String> statusOptions = ['Pending', 'In Progress', 'Completed', 'Cancelled'];

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      selectedAttachmentPaths.value = result.paths.whereType<String>().toList();
    } else {
      Get.snackbar("No file", "Attachment selection canceled", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> submitTodo() async {
    String? authToken = await getAuthToken();
    if (authToken == null) {
      Get.snackbar("Error", "User not authenticated.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (titleController.text.isEmpty || descriptionController.text.isEmpty || selectedPriority.value.isEmpty || !statusOptions.contains(selectedStatus.value)) {
      Get.snackbar("Error", "Please fill in all fields.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      var formData = dio.FormData.fromMap({
        'title': titleController.text,
        'description': descriptionController.text,
        'due_date': DateFormat("yyyy-MM-dd hh:mm a").format(selectedDateTime.value!),
        'priority': selectedPriority.value.toLowerCase(),
        'status': selectedStatus.value,
        'attachment[]': await Future.wait(
          selectedAttachmentPaths.map((path) async {
            return await dio.MultipartFile.fromFile(path, filename: path.split('/').last);
          }),
        ),
      });

      var response = await dio.Dio().post(
        'https://inagold.in/api/store',
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
          },
        ),
      );

      Get.back(); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Todo submitted successfully", snackPosition: SnackPosition.BOTTOM);
        titleController.clear();
        descriptionController.clear();
        selectedDateTime.value = null;
        selectedPriority.value = '';
        selectedStatus.value = '';
        selectedAttachmentPaths.clear();

        Get.off(() => ListTodoPage(), binding: BindingsBuilder(() {
          Get.put(TodoController()).fetchTodos();
        }));
      } else {
        Get.snackbar("Error", "Failed to submit Todo", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "An error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }
}
