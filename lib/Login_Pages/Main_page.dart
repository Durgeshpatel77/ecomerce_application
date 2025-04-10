import 'package:ecomerce_application/Mainpage_Subpages/Tasklist_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Auth_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.list_alt, 'text': 'Tasks'},
    {'icon': Icons.notes, 'text': 'Todos'},
    {'icon': Icons.assignment, 'text': 'Leave'},
    {'icon': Icons.calendar_today_outlined, 'text': 'Calendar'},
    {'icon': Icons.network_cell, 'text': 'Graphs'},
    {'icon': Icons.apartment, 'text': 'Departments'},
    {'icon': Icons.work, 'text': 'Type of work'},
    {'icon': Icons.person, 'text': 'User'},
    {'icon': Icons.settings, 'text': 'Settings'},
    {'icon': Icons.download_outlined, 'text': 'DB Download'},
    {'icon': Icons.file_copy_sharp, 'text': 'File Download'},
    {'icon': Icons.article, 'text': 'Doc Master'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "App Menu",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfffceabb), Color(0xfff8b500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfffceabb), Color(0xfff8b500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Profile section
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/images/images.jpeg'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hello, John Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Lead Manager',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Menu items
              ...menuItems.map((item) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (item['text'] == 'Tasks') {
                      Get.to(() => TasklistPage());
                    } else if (item['text'] == 'Type of work') {
                      Get.to(() => SignUp());
                    } else {
                      print('Tapped on ${item['text']}');
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFFFFF7E6), // soft cream color
                      border: Border.all(
                        color: Colors.white.withAlpha(
                          51,
                        ), // Optional: white border with transparency
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'], size: 26, color: Colors.black),
                        SizedBox(width: 16),
                        Text(
                          item['text'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      body: Container(
        child: Center(
          child: Text(
            'Select an item from the drawer menu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
