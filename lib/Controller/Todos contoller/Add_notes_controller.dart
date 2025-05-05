import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    isLoading.value = true;

    try {
      // 🔐 Fetch auth token
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';

      print("Submitting note with token: $authToken");

      if (authToken.isEmpty) {
        throw Exception("Authentication token not found. Please login again.");
      }

      // ✅ Make the request
      var response = await Dio().post(
        'https://inagold.in/api/todos/add_note/$uuid/save',
        data: {'content': notecontroller.text.trim()},
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
          },
        ),
      );

      print("Note Add Status: ${response.statusCode}");
      if (response.statusCode == 201) {
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
        Get.back(); // ✅ Return to previous screen
      } else {
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
    } on DioError catch (dioError) {
      print("DioError occurred: ${dioError.message}");
      print("Status Code: ${dioError.response?.statusCode}");
      print("Response Data: ${dioError.response?.data}");
      print("Request Headers: ${dioError.requestOptions.headers}");

      Get.snackbar(
        "Dio Error",
        dioError.message ?? "Something went wrong",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error_outline, color: Colors.white),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
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
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    notecontroller.dispose();
    super.onClose();
  }
}
