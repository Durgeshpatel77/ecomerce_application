import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'Auth_Controller.dart';

class TaskController extends GetxController with GetTickerProviderStateMixin {
  var taskList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Tabs
  var selectedTabIndex = 0.obs;
  late TabController tabController;

  final statusTabs = ['not_started', 'in_progress', 'completed'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: statusTabs.length, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        selectedTabIndex.value = tabController.index;
      }
    });

    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading(true);

      final authController = Get.find<AuthController>();
      final accessToken = await authController.getToken();

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

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        taskList.value = List<Map<String, dynamic>>.from(data['data']['data']);
      } else {
        Get.snackbar("Error", "Failed to fetch tasks: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
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
        'Authorization': 'Bearer $accessToken', // Add 'Bearer ' prefix
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final taskData = jsonResponse['data'];

      // Log full task_images array
      print("Raw task_images: ${taskData['task_images']}");

      // Extract and fix image URLs
      final taskImages = taskData['task_images'] as List<dynamic>;
      final imageUrls = taskImages.map((img) {
        final rawUrl = img['image_url'] as String;
        return rawUrl.startsWith('http')
            ? rawUrl
            : 'https://inagold.in$rawUrl'; // Prefix if relative
      }).toList();

      print("Fixed image URLs: $imageUrls");

      return {
        'task': taskData,
        'imageUrls': imageUrls,
      };
    } else {
      throw Exception('Failed to load task details');
    }
  }

  List<Map<String, dynamic>> get filteredTasks {
    final status = statusTabs[selectedTabIndex.value];
    return taskList.where((task) => task['status'] == status).toList();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
