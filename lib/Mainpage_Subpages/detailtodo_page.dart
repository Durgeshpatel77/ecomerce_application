import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import '../Controller/ttodo_controller.dart';  // For using platform channels

class TodoDetailPage extends StatelessWidget {
  final String id;

  const TodoDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TodoController controller = Get.find<TodoController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTodoDetail(id);
    });
    String _format(String? value) {
      if (value == null) return '';
      return value.replaceAll('_', ' ').capitalizeFirst ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _format(controller.todoDetail.value['title']), // Use 'title' from todo map
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
      body: SingleChildScrollView(
        child:
        Obx(() {
          final todo = controller.todoDetail.value;  // Accessing the value from the observable

          if (todo.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final attachments = todo['attachments'] ?? [];
          final notes = todo['notes'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title

                // Subtitle
                if (todo['subtitle'] != null)
                  Text(
                    todo['subtitle'],
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                const SizedBox(height: 16),

                // Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Status: ${todo['status'] ?? ''}')),
                    Chip(label: Text('Priority: ${todo['priority'] ?? ''}')),
                    Chip(label: Text('Work Type: ${todo['work_type'] ?? ''}')),
                    Chip(label: Text('Repeat: ${todo['repeat_task'] ?? ''}')),
                  ],
                ),

                const SizedBox(height: 16),

                // Deadline
                if (todo['deadline'] != null)
                  Text(
                    "Deadline: ${todo['deadline']}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),

                const SizedBox(height: 16),

                // Description
                if ((todo['description'] ?? '').isNotEmpty) ...[
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(todo['description']),
                  const SizedBox(height: 16),
                ],

                // Attachments Section
                if (attachments.isNotEmpty) ...[
                  const Text("Attachments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Column(
                    children: attachments.map<Widget>((attachment) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.attach_file),
                          title: Text(attachment['file_name'] ?? 'No name'),
                          subtitle: Text(attachment['file_type'] ?? 'Unknown type'),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () async {
                              await requestPermissions();
                              await downloadFile(attachment['image_url'], attachment['file_name']);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes Section
                if (notes.isNotEmpty) ...[
                  const Text("Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Column(
                    children: notes.map<Widget>((note) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade50, Colors.purple.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note['content'] ?? '', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(note['user']['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Text("(${note['user']['email'] ?? ''})", style: const TextStyle(fontStyle: FontStyle.italic)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("Created at: ${note['created_at'] ?? ''}"),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

Future<void> requestPermissions() async {
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    Get.snackbar('Permission Denied', 'Please grant storage permission to download the file.');
  }
}

Future<void> downloadFile(String url, String filename) async {
  try {
    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      Get.snackbar('Error', 'Could not access storage directory');
      return;
    }

    final filePath = "${dir.path}/$filename";
    Dio dio = Dio();

    // Add debugging to check if URL and filename are correct
    print("Downloading file from: $url to $filePath");

    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print("Progress: ${(received / total * 100).toStringAsFixed(0)}%");
        }
      },
    );

    // Trigger media scanning so the downloaded file shows up in the gallery
    _scanFile(filePath);

    Get.snackbar('Download Complete', 'File saved to: $filePath');
  } catch (e) {
    print("Download error: $e");
    Get.snackbar('Download Failed', e.toString());
  }
}

// Function to trigger media scanning
Future<void> _scanFile(String filePath) async {
  try {
    const platform = MethodChannel('com.example.app/media');
    await platform.invokeMethod('scanFile', {'path': filePath});
  } on PlatformException catch (e) {
    print("Error scanning file: $e");
  }
}
