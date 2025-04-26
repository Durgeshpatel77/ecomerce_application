import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart'; // 👈 import this

import 'Controller/Auth_Controller.dart';
import 'Controller/TaskList_Controller.dart';
import 'Controller/Taskstatus_contoller.dart';
import 'Controller/http_overrides.dart';
import 'Splash_Screen.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides(); // Set the override
  Get.put(AuthController()); // before runApp()
//  Get.put(TodoStatusController());  // Add this line to register the controller
  Get.put(TaskController());
  Get.put(TaskStatusController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 Run permission check after UI is built
    Future.delayed(Duration.zero, () async {
      final status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        final newStatus = await Permission.manageExternalStorage.request();
        if (!newStatus.isGranted) {
          Get.snackbar(
            'Permission Denied',
            'Please grant storage permission to download the file.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    });

    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}


