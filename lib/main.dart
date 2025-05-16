import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart'; // 👈 import this

import 'Controller/Auth_Controller.dart';
import 'Controller/Task controller/TaskList_Controller.dart';
import 'Controller/Task controller/Taskstatus_contoller.dart';
import 'Controller/Todos controller/Ttodostatus_controller.dart';
import 'Controller/Todos controller/ttodo_controller.dart';
import 'Controller/http_overrides.dart';
import 'Splash_Screen.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides(); // Set the override
  Get.put(AuthController()); // before runApp()
//  Get.put(TodoStatusController());  // Add this line to register the controller
  Get.put(TaskController());
  Get.put(TaskStatusController());
  Get.put(TodoController());
  Get.put(TodoStatusController());

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
              backgroundColor: Colors.red,
              snackPosition: SnackPosition.BOTTOM,
              icon: Icon(Icons.cancel, size: 33,color: Colors.white,),
              duration: Duration(seconds: 2),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),  // Custom padding
              colorText: Colors.white
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


