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

  // Added: observable variables to hold user info
  var userName = ''.obs;
  var userEmail = ''.obs;

  void loginApi() async {
    if (codeController.text.length != 6) {
      Get.snackbar(
        "Error",
        "Please enter a valid 6-digit code",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
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
        final fullToken = "$tokenType $token";
        print("Full Token: $fullToken"); // 👈 Add this line to print token

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', fullToken);

        // 🔽 Fetch user info from separate API after saving token
        await fetchUserInfo();

        Get.snackbar(
          "Success",
          "Login successful!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );

        Get.off(() => HomeScreen());
      } else {
        Get.snackbar(
          "Error",
          "Login failed Enter Valid Code",
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

  // 🔽 Added: fetch user info using separate API after login
  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://inagold.in/api/get_user_info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      print("User Info Status: ${response.statusCode}");
      print("User Info Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('user') && data['user'] != null) {
          final user = data['user'];
          userName.value = user['name'] ?? '';
          userEmail.value = user['email'] ?? '';

          await prefs.setString('user_name', userName.value);
          await prefs.setString('user_email', userEmail.value);
        }
      }
    } catch (e) {
      print("User Info Error: $e");
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<bool> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('access_token');
  }

  // 🔽 Load user info from shared preferences if already stored
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('user_name') ?? '';
    userEmail.value = prefs.getString('user_email') ?? '';
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }
}
