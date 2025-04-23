import 'dart:convert';
import 'dart:io';
import 'package:ecomerce_application/Controller/ttodo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Mainpage_Subpages/Todos/listtodo_page.dart';

class AddTodoController extends GetxController {
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var selectedDateTime = Rxn<DateTime>();
  var selectedPriority = "".obs;
  var selectedStatus = "".obs;
  var selectedAttachmentPath = "".obs;

  List<String> priorityOptions = ['Low', 'Medium', 'High'];
  List<String> statusOptions = ['Pending', 'In Progress', 'Completed', 'Cancelled'];

  // Date selection function
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

  // Function to pick attachment
  Future<void> pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      selectedAttachmentPath.value = result.files.single.path!;
    } else {
      Get.snackbar("No file", "Attachment selection canceled", snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Fetch auth token from SharedPreferences
  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print("Fetched Auth Token: $token"); // Debugging line
    return token;
  }

  // Submit Todo
  Future<void> submitTodo() async {
    String? authToken = await getAuthToken();

    if (authToken == null) {
      Get.snackbar("Error", "User not authenticated. Please log in.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (selectedPriority.value.isEmpty) {
      Get.snackbar("Error", "Please select a priority.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!['Pending', 'In Progress', 'Completed', 'Cancelled'].contains(selectedStatus.value)) {
      Get.snackbar("Error", "Invalid status selected.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://inagold.in/api/store'),
      );

      request.fields['title'] = titleController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['due_date'] = DateFormat("yyyy-MM-dd hh:mm a").format(selectedDateTime.value!);
      request.fields['priority'] = selectedPriority.value.toLowerCase();
      request.fields['status'] = selectedStatus.value;
      request.headers['Authorization'] = 'Bearer $authToken';

      if (selectedAttachmentPath.value.isNotEmpty) {
        var file = await http.MultipartFile.fromPath('attachment', selectedAttachmentPath.value);
        request.files.add(file);
      }

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      Get.back(); // Close the loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Todo submitted successfully", snackPosition: SnackPosition.BOTTOM);

        // Clear form
        titleController.clear();
        descriptionController.clear();
        selectedDateTime.value = null;
        selectedPriority.value = '';
        selectedStatus.value = '';
        selectedAttachmentPath.value = '';

        // Navigate to todo list page (replace with your actual route/page)
        Get.off(() => ListTodoPage(), binding: BindingsBuilder(() {
          Get.put(TodoController()).fetchTodos();
        }));      } else {
        Get.snackbar("Error", "Failed to submit Todo", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.back(); // Close the loading dialog if error occurs
      Get.snackbar("Error", "An error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }
}