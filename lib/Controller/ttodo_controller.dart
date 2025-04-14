import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoController extends GetxController {
  var todoList = [].obs;
  var isLoading = false.obs;

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

      final response = await http.get(
        Uri.parse('https://inagold.in/api/get_todo_list?page=1'),
        headers: {'Authorization': token, 'Accept': 'application/json'},
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final todos = data['data']['data']; // access nested "data" list
        todoList.assignAll(todos);
      } else {
        Get.snackbar("Error", "Failed to fetch todos");
      }
    } catch (e) {
      print("Error fetching todos: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
