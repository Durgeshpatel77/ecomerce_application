import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddNotesController extends GetxController {
  var isLoading = false.obs;
  var notecontroller = "".obs;

  Future<void> submitNotes(String uuid, String authToken) async {
    final content = notecontroller.value.trim();

    if (content.isEmpty) {
      Get.snackbar(
        "Error",
        "Notes content can not be empty",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
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
      print("Add mote status code is:${response.statusCode}");

      if (data['success'] == true) {
        Get.snackbar(
          "Success",
          data['message'] ?? "Note added successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );
        notecontroller.value = ''; // Clear the text after submission
      } else {
        Get.snackbar(
          "Error",
          "Failed to add note",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
