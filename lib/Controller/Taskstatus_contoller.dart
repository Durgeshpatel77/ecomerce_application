import 'dart:convert';

import 'package:ecomerce_application/Controller/Auth_Controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'Auth_Controller.dart';

class TaskStatusController extends GetxController {
  var statusList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedStatus = Rxn<Map<String, dynamic>>(); // 👈 Holds selected status


  Future<void> fetchStatuses() async {
    isLoading.value = true;
    try {

      final authController =Get.find<AuthController>();
      final accessToken =await authController.getToken();

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar("Auth Error", "No access token. Please login.");
        return;
      }

      final response=await http.get(Uri.parse("https://inagold.in/api/task_status"),
        headers: {
          'Authorization': 'Bearer $accessToken', // ✅ Use token here
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
}
