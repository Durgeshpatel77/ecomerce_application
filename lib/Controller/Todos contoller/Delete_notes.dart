import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NoteController extends GetxController {
  var isDeleting = false.obs;

  // Method to delete note by ID
  Future<void> deleteNoteById(int noteId, String authToken) async {
    final url = Uri.parse("https://inagold.in/api/todos/delete_note/$noteId");
    isDeleting.value = true;

    try {
      // Fetch the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';

      // Check if the token is empty, if so, prompt the user to log in
      if (authToken.isEmpty) {
        Get.snackbar(
          "Error",
          "Please log in again.",
          backgroundColor: Colors.red.shade400,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      print('Token: $authToken'); // Debug

      // Perform the DELETE request
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      print("Delete notes status code ${response.statusCode}");

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Note deleted successfully");
      } else {
        Get.snackbar("Error", "Failed to delete note (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception occurred: $e");
    } finally {
      isDeleting.value = false;
    }
  }
}
