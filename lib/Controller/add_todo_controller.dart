import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    // Ensure user is authenticated
    String? authToken = await getAuthToken();

    if (authToken == null) {
      Get.snackbar("Error", "User not authenticated. Please log in.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Validate the status value to be one of the allowed values
    if (!['Pending', 'In Progress', 'Completed', 'Cancelled'].contains(selectedStatus.value)) {
      Get.snackbar("Error", "Invalid status selected.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://inagold.in/api/store'),
      );

      request.fields['title'] = titleController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['due_date'] = DateFormat("yyyy-MM-dd hh:mm a").format(selectedDateTime.value!);
      request.fields['priority'] = selectedPriority.value.toLowerCase(); // Ensure priority is formatted correctly
      request.fields['status'] = selectedStatus.value; // Status should be a valid value

      // Add Authorization header
      request.headers['Authorization'] = 'Bearer $authToken'; // Add the token here

      if (selectedAttachmentPath.value.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'attachment',
          selectedAttachmentPath.value,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Status Code of add todo: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Todo submitted", snackPosition: SnackPosition.BOTTOM);

        // Reset form
        titleController.clear();
        descriptionController.clear();
        selectedDateTime.value = null;
        selectedPriority.value = '';
        selectedStatus.value = '';
        selectedAttachmentPath.value = '';
      } else {
        Get.snackbar("Error", "Failed to submit Todo", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }
}
