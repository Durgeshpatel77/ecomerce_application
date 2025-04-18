import 'dart:convert';
import 'package:ecomerce_application/Controller/Auth_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TodoStatusController extends GetxController {
  var statusList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedStatus = Rxn<Map<String, dynamic>>();  // Stores the selected status
  var todoList = <Map<String, dynamic>>[].obs;

  void updateTodoStatusInUI(String todoUuid, String newStatus) {
    final index = todoList.indexWhere((todo) => todo['uuid'] == todoUuid);
    if (index != -1) {
      todoList[index]['status'] = newStatus;
      todoList.refresh(); // Notify GetX listeners to update the UI
    }
  }

  /// Fetch all todo statuses
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
        Uri.parse("https://inagold.in/api/todo_status"),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      print('Todo Status API status code: ${response.statusCode}');
      print('Todo Status API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        statusList.value = List<Map<String, dynamic>>.from(data['data']);
      } else {
        Get.snackbar("Error", "Failed to load todo statuses");
      }
    } catch (e) {
      print('Error fetching todo statuses: $e');
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Update todo status by UUID
  Future<void> updateTodoStatus(String uuid) async {
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
        Uri.parse("https://inagold.in/api/update_todo_status/$uuid"), // Update this endpoint
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'status': statusValue, // ✅ Only status is needed
        }),
      );

      print("Update Todo Status API Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final oldStatus = data['data']['old_status'];
        final newStatus = data['data']['new_status'];

        if (oldStatus == newStatus) {
          Get.snackbar(
            "Info",
            "Todo status was already in '$newStatus'",
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            "Success",
            "Todo status changed from '$oldStatus' to '$newStatus'",
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to update todo status",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Exception",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
