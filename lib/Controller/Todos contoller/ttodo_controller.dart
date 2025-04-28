import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoController extends GetxController {
  var todoList = [].obs;
  var isLoading = false.obs;

  var statusCount = <String, dynamic>{
    'pending': 0,
    'completed': 0,
    'in_progress': 0,
    'cancelled': 0,
    'total': 0,
  }.obs;

  // Detail for a single todo
  var todoDetail = <String, dynamic>{}.obs;

  // Helper method to retrieve the token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); // Ensure the key matches
    print("Token retrieved from SharedPreferences: $token"); // Debugging line
    return token;
  }

  // Fetch todo list and status counts
  Future<void> fetchTodos() async {
    isLoading.value = true;

    try {
      final token = await getToken();
      print("Token of todos: $token"); // Debugging line

      // Check if token is found
      if (token == null) {
        Get.snackbar(
          "Error",
          "No token found. Please login again.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.cancel, size: 33, color: Colors.white),
          duration: Duration(seconds: 2),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // Fetch todo list
      final response = await http.get(
        Uri.parse('https://inagold.in/api/get_todo_list?page=1'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      // Fetch status count
      final statusResponse = await http.get(
        Uri.parse('https://inagold.in/api/count_todos'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      print("Todo List Status Code: ${response.statusCode}");
      print("Todo List Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final todos = data['data']['data'];
        todoList.assignAll(todos);
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch todos. Status Code: ${response.statusCode}",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.cancel, size: 33, color: Colors.white),
          duration: Duration(seconds: 2),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          colorText: Colors.white,
        );
      }

      print("Status Count Status Code: ${statusResponse.statusCode}");
      print("Status Count Response Body: ${statusResponse.body}");

      if (statusResponse.statusCode == 200) {
        final statusData = jsonDecode(statusResponse.body);
        final statusMap = Map<String, dynamic>.from(statusData['data']);
        statusCount.assignAll(statusMap);
        print("Updated Status Count: $statusCount");
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch status counts. Status Code: ${statusResponse.statusCode}",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.cancel, size: 33, color: Colors.white),
          duration: Duration(seconds: 2),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error fetching todos: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while fetching todos.",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
