import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Login_Pages/Auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    requestPermissionsAndNavigate();
  }

  Future<void> requestPermissionsAndNavigate() async {
    // Request permissions
    await [
      Permission.location,
      Permission.photos,
      Permission.storage,
    ].request();

    // Wait 3 seconds before navigating
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return; // Prevents errors if widget is disposed
    Get.off(() => const SignUp());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Image.asset(
          'assets/images/splash.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
