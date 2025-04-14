import 'package:ecomerce_application/Mainpage_Subpages/Tasklist_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/Auth_Controller.dart';
import '../Mainpage_Subpages/listtodo_page.dart';


class HomeScreen extends StatelessWidget  {
  final AuthController userController = Get.put(AuthController());

  @override

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.list_alt, 'text': 'Tasks'},
    {'icon': Icons.notes, 'text': 'Todos'},
    {'icon': Icons.logout, 'text': 'Logout'},
  ];

  @override
  Widget build(BuildContext context) {
    userController.loadUserFromPrefs(); // Load saved user info

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("App Menu", style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    Obx(() => Text(
                      userController.userName.value,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    )),
                    Obx(() => Text(
                      userController.userEmail.value,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    )),
                  ],
                ),
              ),
              ...menuItems.map((item) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (item['text'] == 'Tasks') {
                      Get.to(() => TasklistPage());
                    } else if (item['text'] == 'Todos') {
                      Get.to(() => ListTodoPage());

                    }
                    else if (item['text'] == 'Logout') {
                      Get.find<AuthController>().logout();
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFFFFF7E6),
                      border: Border.all(color: Colors.white.withAlpha(51)),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'], size: 26, color: Colors.black),
                        SizedBox(width: 16),
                        Text(item['text'], style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (context) {
              final width = MediaQuery.of(context).size.width;
              final height = MediaQuery.of(context).size.height;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tasks & Activities',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text('Active', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track and manage your task progress and team activities',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2; // 3 columns in landscape/tablet, 2 in portrait
                      double childAspectRatio = constraints.maxWidth > 600 ? 1.3 : 0.9;

                      return GridView.builder(
                        itemCount: 9,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 10,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          final cards = [
                            buildTaskCard(Icons.calendar_today, "Today's Tasks", "All tasks created today", "1", "7.1%", Colors.blue),
                            buildTaskCard(Icons.check_circle, "Completed Tasks", "All completed tasks", "6", "42.9%", Colors.green),
                            buildTaskCard(Icons.timelapse, "Active Tasks", "Total ongoing tasks", "8", "57.1%", Colors.orange),
                            buildTaskCard(Icons.pending_actions, "Pending Tasks", "All pending tasks", "7", "50%", Colors.deepPurple),
                            buildTaskCard(Icons.note_add, "Today's Todos", "All todos created today", "0", "0%", Colors.indigo),
                            buildTaskCard(Icons.assignment_turned_in, "Completed Todos", "All completed todos", "0", "0%", Colors.teal),
                            buildTaskCard(Icons.event_busy, "Users on Leave", "Today", "0", "0%", Colors.brown),
                            buildTaskCard(Icons.event_available, "Users on Leave", "This Week", "0", "0%", Colors.amber),
                            buildTaskCard(Icons.event_note, "Users on Leave", "This Month", "0", "0%", Colors.deepOrange),
                          ];

                          return cards[index];
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
      );
    }
  }

Widget buildTaskCard(IconData icon, String title, String subtitle, String count, String percent, Color color) {
  return InkWell(
    onTap: () {
      // You can customize this tap behavior later
      Get.snackbar(title, "Card tapped", snackPosition: SnackPosition.BOTTOM);
    },
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFF1D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 22),
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    count,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Row(
                    children: [
                      Icon(Icons.arrow_upward, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(percent, style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          SizedBox(height: 12),
          Spacer(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              "View details",
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ),
  );
}
