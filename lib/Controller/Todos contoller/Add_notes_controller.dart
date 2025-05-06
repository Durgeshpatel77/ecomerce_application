import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddNoteController extends GetxController {
  var isLoading = false.obs;

  Future<void> submitNote(String uuid, String content) async {
    isLoading.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        Get.snackbar("Error", "No token found");
        return;
      }

      final url = Uri.parse("https://inagold.in/api/todos/add_note/$uuid/save");
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {'content': content},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Get.back(result: data['data']); // Return note to previous screen
        Get.snackbar("Success", data['message']);
      } else {
        Get.snackbar("Failed", data['message'] ?? "Something went wrong");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to submit note: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
