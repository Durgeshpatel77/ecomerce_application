import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Auth_Controller.dart';

class TaskController extends GetxController with GetTickerProviderStateMixin {
  var taskList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Tabs
  var selectedTabIndex = 0.obs;
  late TabController tabController;

  final statusTabs = ['not_started', 'in_progress', 'done', 'delayed'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: statusTabs.length, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        selectedTabIndex.value = tabController.index;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    fetchTasks(); // Fetch tasks when screen becomes visible
  }

  // Auth_Controller.dart
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('Access token fetched from SharedPreferences: $token');
    return token;
  }

  Future<void> saveToken(String token, String tokenType) async {
    final prefs = await SharedPreferences.getInstance();
    final fullToken = '$tokenType $token';
    await prefs.setString('access_token', fullToken);
    print("Token saved to SharedPreferences: $fullToken");
  }

  Future<void> fetchTasks() async {
    try {
      isLoading(true);

      final authController = Get.find<AuthController>();
      final accessToken = await authController.getToken();
      print("Fetched Access Token in fetchTasks: $accessToken");

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar("Auth Error", "No access token. Please login.");
        return;
      }

      final response = await http.get(
        Uri.parse("https://inagold.in/api/get_task_list?page=1"),
        headers: {
          'Accept': 'application/json',
          'Authorization': accessToken,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        taskList.value = List<Map<String, dynamic>>.from(data['data']['data']);
      } else {
        Get.snackbar("Error", "Failed to fetch tasks: ${response.statusCode}",
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM,
            icon: Icon(Icons.cancel, size: 33, color: Colors.white),
            duration: Duration(seconds: 2),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString(),
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.cancel, size: 33, color: Colors.white),
          duration: Duration(seconds: 2),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> getTaskDetailById(String taskId) async {
    final authController = Get.find<AuthController>();
    final accessToken = await authController.getToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("No access token available.");
    }

    final response = await http.get(
      Uri.parse('https://inagold.in/api/get_task_details/$taskId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    print("Task list response code:${response.statusCode}");
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final taskData = jsonResponse['data'];

      final taskImages = taskData['task_images'] as List<dynamic>;
      final imageUrls = taskImages.map((img) {
        final rawUrl = img['image_url'] as String;
        return rawUrl.startsWith('http') ? rawUrl : 'https://inagold.in$rawUrl';
      }).toList();

      return {
        'task': taskData,
        'uuid': taskData['uuid'],
        'imageUrls': imageUrls,
      };
    } else {
      throw Exception('Failed to load task details');
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
