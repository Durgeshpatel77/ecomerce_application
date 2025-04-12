import 'dart:convert';
import 'package:ecomerce_application/Controller/Auth_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TaskStatusController extends GetxController {
  var statusList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedStatus = Rxn<Map<String, dynamic>>();
  var taskList = <Map<String, dynamic>>[].obs;

  void updateTaskStatusInUI(String taskUuid, String newStatus) {
    final index = taskList.indexWhere((task) => task['uuid'] == taskUuid);
    if (index != -1) {
      taskList[index]['status'] = newStatus;
      taskList.refresh(); // Notify GetX listeners to update the UI
    }
  }

  /// Fetch all task statuses
  Future<void> fetchStatuses() async {
    isLoading.value = true;
    try {
      final authController = Get.find<AuthController>();
      final accessToken = await authController.getToken();

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar("Auth Error", "No access token. Please login.");
        return;
      }

      final response = await http.get(
        Uri.parse("https://inagold.in/api/task_status"),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      print('Task Status API status code: ${response.statusCode}');
      print('Task Status API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        statusList.value = List<Map<String, dynamic>>.from(data['data']);
      } else {
        Get.snackbar("Error", "Failed to load task statuses");
      }
    } catch (e) {
      print('Error fetching task statuses: $e');
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Update task status by UUID
  Future<void> updateTaskStatus(String uuid) async {
    if (selectedStatus.value == null) {
      Get.snackbar("Error", "No status selected");
      return;
    }

    final statusValue = selectedStatus.value!['value'];
    try {
      final authController = Get.find<AuthController>();
      final accessToken = await authController.getToken();

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar("Auth Error", "No access token. Please login.");
        return;
      }

      final response = await http.post(
        Uri.parse("https://inagold.in/api/update_status/$uuid"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'status': statusValue, // ✅ Only status is needed
        }),
      );

      print("Update Status API Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final oldStatus = data['data']['old_status'];
        final newStatus = data['data']['new_status'];

        if (oldStatus == newStatus) {
          Get.snackbar(
            "Info",
            "Status was already in '$newStatus'",
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            "Success",
            "Status changed from '$oldStatus' to '$newStatus'",
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to update status",
          backgroundColor: Colors.red,
          maxWidth: 20,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Exception",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        maxWidth: 20,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
