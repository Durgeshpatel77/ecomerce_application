import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Login_Pages/Auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNext();
      }
    });

    _controller.forward();
    requestPermissions();  // Request permissions before navigating
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
      Permission.photos,
      Permission.mediaLibrary,
      Permission.location,
    ].request();

    // Check and notify if any were denied
    statuses.forEach((perm, status) {
      if (status.isDenied || status.isPermanentlyDenied) {
        Get.snackbar(
          'Permission Error',
          '$perm permission not granted. Please enable it in settings.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  Future<void> requestStoragePermission() async {
    // Requesting MANAGE_EXTERNAL_STORAGE permission on Android 11+
    if (await Permission.manageExternalStorage.isPermanentlyDenied) {
      openAppSettings();
    } else {
      PermissionStatus status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        print("Storage permission granted.");
      } else {
        print("Storage permission denied.");
      }
    }

    // Request regular storage permission if needed
    PermissionStatus status = await Permission.storage.request();
    print("Storage permission status before request: $status");

    if (!status.isGranted) {
      status = await Permission.storage.request();
      print("Storage permission status after request: $status");

      if (status.isPermanentlyDenied) {
        Get.snackbar('Permission Denied', 'Permission permanently denied. Please enable it in settings.');
        openAppSettings();
      } else {
        Get.snackbar('Permission Denied', 'Storage permission not granted. Please enable it.');
      }
    }
  }

  void _navigateToNext() {
    if (mounted) {
      Get.off(() => const AuthScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF90CAF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  "Task Manager",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _controller.value,
                        minHeight: 8,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  "Getting things ready...",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
