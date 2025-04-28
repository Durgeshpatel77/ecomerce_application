import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Login_Pages/Auth_screen.dart';
import '../Login_Pages/Main_page.dart';

class AuthController extends GetxController {
  final codeController = TextEditingController();
  var isLoading = false.obs;

  // Observable variables to hold user info
  var userName = ''.obs;
  var userEmail = ''.obs;

  // Method for login API
  void loginApi() async {
    if (codeController.text.length != 6) {
      Get.snackbar(
        "Error",
        "Please enter a valid code",
        backgroundColor: Colors.red.shade400,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error, size: 33, color: Colors.white),
        duration: Duration(seconds: 2),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Custom padding
        colorText: Colors.white,
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
        print("Access Token: $token");
        print("Token Type: $tokenType");
        print("Full Token: $fullToken");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', fullToken);

        print("Token saved to SharedPreferences: ${fullToken}");

        await fetchUserInfo();

        Get.snackbar(
          "Success",
          "Login successful!",
          backgroundColor: Colors.green.shade400,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.check_circle, size: 33, color: Colors.white),
          duration: Duration(seconds: 2),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Custom padding
          colorText: Colors.white,
        );
        codeController.clear(); // Clear the field here ✅

        Get.off(() => HomeScreen());
      } else {
        Get.snackbar(
          "Error", "Login failed. Enter a valid code.",
          backgroundColor: Colors.red.shade50,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.check_circle, size: 33, color: Colors.white),
          duration: Duration(seconds: 2),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Custom padding
          colorText: Colors.white,
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

  // Method to fetch user info from the server
  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

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

  // Logout method to clear stored token and user info
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');

    userName.value = '';
    userEmail.value = '';

    print("✅ Logout successful. Token and user data cleared.");

    Get.offAll(() => AuthScreen());

    Get.snackbar(
      "Logged Out",
      "You have been logged out successfully.....",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
    );
  }

  // Method to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Ensure you are using the correct key
  }

  // Load user data from shared preferences
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('user_name') ?? '';
    userEmail.value = prefs.getString('user_email') ?? '';
  }

  // Called when the controller is closed to dispose of the text controller
  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }
}
