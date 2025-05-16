import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NoteController extends GetxController {
  var isDeleting = false.obs;

  // Now returns bool to indicate success/failure
  Future<bool> deleteNoteById(int noteId, String authToken) async {
    final url = Uri.parse("https://inagold.in/api/todos/delete_note/$noteId");
    isDeleting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';

      if (authToken.isEmpty) {
        Get.snackbar(
          "Error",
          "Please log in again.",
          backgroundColor: Colors.red.shade400,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      print("Delete notes status code ${response.statusCode}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete note: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception during delete: $e");
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
