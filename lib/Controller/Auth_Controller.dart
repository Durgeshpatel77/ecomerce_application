import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Login_Pages/Main_page.dart';

class AuthController extends GetxController {
  final codeController = TextEditingController();
  var isLoading = false.obs;

  void loginApi() async {
    if (codeController.text.length != 6) {
      Get.snackbar(
        "Error",
        "Please enter a valid 6-digit code",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('https://inagold.in/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'security_code': codeController.text}),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final tokenType = data['token_type'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', "$tokenType $token");

        Get.snackbar(
          "Success",
          "Login successful!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );

        Get.to(() => MenuScreen());
      } else {
        Get.snackbar(
          "Error",
          "Login failed: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("Login Error: $e");
      Get.snackbar(
        "Error",
        "Something went wrong. Try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }
}
