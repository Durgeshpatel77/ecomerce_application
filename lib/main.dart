import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Controller/Auth_Controller.dart';
import 'Controller/http_overrides.dart';
import 'Splash_Screen.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides(); // Set the override
  Get.put(AuthController()); // before runApp()
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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


