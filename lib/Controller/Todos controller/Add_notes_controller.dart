import 'dart:convert';
import 'package:ecomerce_application/Mainpage_Subpages/Todos/detailtodo_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddNotesController extends GetxController {
  var notecontroller = TextEditingController();
  var isLoading = false.obs;

  Future<void> submitNotes(String uuid, String authToken) async {
    if (notecontroller.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Note content cannot be empty.",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.warning, color: Colors.white),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      return;
    }

    isLoading.value = true;  // Show loading indicator

    try {
      // Fetch token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? authToken;

      print("Auth Token: $authToken");
      print("Retrieved Token: $token");

      if (token.isEmpty) {
        throw Exception("Authentication token not found. Please login again.");
      }

      // Prepare request
      final url = Uri.parse('https://inagold.in/api/todos/add_note/$uuid/save');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': notecontroller.text.trim(),
        }),
      );

      print("Note Add Status: ${response.statusCode}");

      if (response.statusCode == 201) {
        // Show success snackbar and navigate back
        Get.snackbar(
          "Success",
          "Note added successfully",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.check_circle, color: Colors.white),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
        notecontroller.clear();
        Navigator.of(Get.context!).pop(); // <- Use Navigator to go back
      } else {
        // Handle failure
        print("Response Body: ${response.body}");
        Get.snackbar(
          "Failed",
          "Note not added. Try again.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.error, color: Colors.white),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print("Unexpected error: $e");
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.cancel, color: Colors.white),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;  // Hide loading indicator
    }
  }

  @override
  void onClose() {
    notecontroller.dispose(); // Clean up controller
    super.onClose();
  }
}
