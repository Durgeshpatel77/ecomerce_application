import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Controller/ttodo_controller.dart';

class TodoDetailPage extends StatelessWidget {
  final String id;

  const TodoDetailPage({Key? key, required this.id}) : super(key: key);

  // Request storage and manage storage permissions
  Future<void> requestPermissions() async {
    final storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      Get.snackbar('Permission Denied', 'Storage permission not granted. Please enable it.');
      return;
    }

    final manageStatus = await Permission.manageExternalStorage.request();
    if (!manageStatus.isGranted) {
      Get.snackbar('Permission Denied', 'Full storage permission not granted. Please enable it.');
      return;
    }

  }

  // Method to handle file download
  Future<void> downloadFile(String url, String fileName) async {
    if (!(await Permission.storage.isGranted) || !(await Permission.manageExternalStorage.isGranted)) {
      Get.snackbar('Permission Denied', 'Storage permission not granted. Please enable it.');
      return;
    }

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = '${appDocDir.path}/$fileName';

      Dio dio = Dio();
      await dio.download(url, savePath);

      Get.snackbar('Download Complete', 'File has been downloaded to $savePath');
    } catch (e) {
      Get.snackbar('Download Failed', 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TodoController controller = Get.find<TodoController>();

    // Request permission on the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissions(); // Request permissions when the page is loaded
      controller.fetchTodoDetail(id);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Todo Details")),
      body: SingleChildScrollView(
        child: Obx(() {
          final todo = controller.todoDetail;

          if (todo.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract attachments and notes from the response
          final attachments = todo['attachments'] ?? [];
          final notes = todo['notes'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Title: ${todo['title'] ?? ''}", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("Status: ${todo['status'] ?? ''}"),
                const SizedBox(height: 10),
                Text("Description: ${todo['description'] ?? ''}"),
                const SizedBox(height: 20),

                // Display attachments
                Text("Attachments:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...attachments.map<Widget>((attachment) {
                  return ListTile(
                    title: Text(attachment['file_name']),
                    subtitle: Text(attachment['file_type']),
                    trailing: IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () {
                        downloadFile(attachment['image_url'], attachment['file_name']);
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),

                // Display notes
                Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...notes.map<Widget>((note) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note['content'], style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              Text(note['user']['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text("(${note['user']['email']})", style: TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Created at: ${note['created_at']}"),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }),
      ),
    );
  }
}
