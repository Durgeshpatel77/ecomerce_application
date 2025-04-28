import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddNotesController extends GetxController {
  var isLoading = false.obs;
  final TextEditingController notecontroller = TextEditingController();

  Future<void> submitNotes(String uuid, String authToken) async {
    final content = notecontroller.text.trim();

    if (content.isEmpty) {
      Get.snackbar(
        "Error",
        "Notes content can not be empty",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.cancel, size: 33,color: Colors.white,),
          duration: Duration(seconds: 2),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),  // Custom padding
          colorText: Colors.white
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse("https://inagold.in/api/todos/add_note/$uuid/save"),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({"content": content}),
      );

      final data = jsonDecode(response.body);
      print("Add note status code is: ${response.statusCode}");

      if (data['success'] == true) {
        Get.snackbar(
          "Success",
          data['message'] ?? "Note added successfully",
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
            icon: Icon(Icons.check_circle, size: 33,color: Colors.white,),
            duration: Duration(seconds: 2),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),  // Custom padding
            colorText: Colors.white  );
        notecontroller.clear(); // Clear the text field
        await Future.delayed(const Duration(seconds: 1)); // (optional) short delay to show the snackbar
        Get.back(); // 👈 go back and return true to previous screen
      }
      else {
        Get.snackbar(
          "Error",
          "Failed to add note",
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM,
            icon: Icon(Icons.cancel, size: 33,color: Colors.white,),
            duration: Duration(seconds: 2),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),  // Custom padding
            colorText: Colors.white

        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.cancel, size: 33,color: Colors.white,),
          duration: Duration(seconds: 2),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),  // Custom padding
          colorText: Colors.white
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
