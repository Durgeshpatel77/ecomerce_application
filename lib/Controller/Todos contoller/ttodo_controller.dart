import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Auth_Controller.dart';

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

  var todoDetail = <String, dynamic>{}.obs;

  final authController = Get.find<AuthController>(); // Get AuthController instance

  Future<void> fetchTodos() async {
    isLoading.value = true;

    try {
      final token = await authController.getToken(); // ✅ Fetch token from SharedPreferences
      if (token == null || token.isEmpty) {
        _showTokenError();
        return;
      }

      final response = await http.get(
        Uri.parse('https://inagold.in/api/get_todo_list?page=1'),
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
        },
      );

      final statusResponse = await http.get(
        Uri.parse('https://inagold.in/api/count_todos'),
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final todos = data['data']['data'];
        todoList.assignAll(todos);
      } else {
      //  _showError("Failed to fetch todos. Status Code: ${response.statusCode}");
      }

      if (statusResponse.statusCode == 200) {
        final statusData = jsonDecode(statusResponse.body);
        final statusMap = Map<String, dynamic>.from(statusData['data']);
        statusCount.assignAll(statusMap);
      } else {
      //  _showError("Failed to fetch status counts. Status Code: ${statusResponse.statusCode}");
      }
    } catch (e) {
      _showError("Something went wrong while fetching todos.");
      print("Error fetching todos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> fetchTodoDetail(String id) async {
    isLoading.value = true;

    try {
      final token = await authController.getToken(); // ✅ Fetch token again
      if (token == null || token.isEmpty) {
        _showTokenError();
        return {};
      }

      final response = await http.get(
        Uri.parse('https://inagold.in/api/get_todo_details/$id'),
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        todoDetail.value = data['data'] ?? {};
        return todoDetail.value; // Return the data if needed elsewhere
      } else {
        _showError("Failed to fetch todo details. Status Code: ${response.statusCode}");
        return {}; // Empty map in case of failure
      }
    } catch (e) {
      _showError("Something went wrong while fetching todo details.");
      print("Error fetching todo detail: $e");
      return {}; // Empty map in case of error
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(Icons.cancel, size: 33, color: Colors.white),
      duration: Duration(seconds: 2),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      colorText: Colors.white,
    );
  }

  void _showTokenError() {
    _showError("No token found. Please login again.");
    isLoading.value = false;
  }
}
