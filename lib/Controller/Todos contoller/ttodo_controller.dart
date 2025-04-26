import 'dart:convert';
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

  // Fetch todo list and status counts
  Future<void> fetchTodos() async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        Get.snackbar("Error", "No token found. Please login again.");
        isLoading.value = false;
        return;
      }

      // Fetch todo list
      final response = await http.get(
        Uri.parse('https://inagold.in/api/get_todo_list?page=1'),
        headers: {'Authorization': token, 'Accept': 'application/json'},
      );

      // Fetch status count
      final statusResponse = await http.get(
        Uri.parse('https://inagold.in/api/count_todos'),
        headers: {'Authorization': token, 'Accept': 'application/json'},
      );

      print("Todo List Status Code: ${response.statusCode}");
      print("Todo List Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final todos = data['data']['data'];
        todoList.assignAll(todos);
      } else {
      //  Get.snackbar("Error", "Failed to fetch todos");
      }

      print("Status Count Status Code: ${statusResponse.statusCode}");
      print("Status Count Response Body: ${statusResponse.body}");

      if (statusResponse.statusCode == 200) {
        final statusData = jsonDecode(statusResponse.body);
        final statusMap = Map<String, dynamic>.from(statusData['data']);
        statusCount.assignAll(statusMap);
        print("Updated Status Count: $statusCount");
      } else {
      //  Get.snackbar("Error", "Failed to fetch status counts");
      }
    } catch (e) {
      print("Error fetching todos: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch detail of a specific todo by UUID
  Future<void> fetchTodoDetail(String id) async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        Get.snackbar("Error", "No token found. Please login again.");
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse('https://inagold.in/api/get_todo_details/$id'),
        headers: {'Authorization': token, 'Accept': 'application/json'},
      );

      print("Todo Detail Response Code: ${response.statusCode}");
      print("Todo Detail Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        todoDetail.value = data['data'] ?? {};
      } else {
        //Get.snackbar("Error", "Failed to fetch todo details");
      }
    } catch (e) {
      print("Error fetching todo detail: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
