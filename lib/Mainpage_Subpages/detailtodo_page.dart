import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../All_custom_widgets/FormattedDateTime_custom.dart';
import '../Controller/ttodo_controller.dart';

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
        title: Obx(() {
          final title = controller.todoDetail.value['title'];
          return Text(
            _format(title),
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
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
      body: Obx(() {
        final todo = controller.todoDetail.value;

        if (todo.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final attachments = todo['attachments'] ?? [];
        final notes = todo['notes'] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              /// === CONTAINER 1: Task Info ===
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xfffceabb), Color(0xfff8b500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Task Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Status: ${todo['status'] ?? ''}')),
                        Chip(label: Text('Priority: ${todo['priority'] ?? ''}')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (todo['due_date'] != null)
                      Row(
                        children: [
                          const Text("Deadline: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          FormattedDateTimeText(isoString: todo['due_date']),
                        ],
                      ),
                    if (todo['completed_at'] != null)
                      Row(
                        children: [
                          const Text("Completed At: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          FormattedDateTimeText(isoString: todo['completed_at']),
                        ],
                      ),
                    if (todo['created_at'] != null)
                      Row(
                        children: [
                          const Text("Created At: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          FormattedDateTimeText(isoString: todo['created_at']),
                        ],
                      ),
                    if (todo['updated_at'] != null)
                      Row(
                        children: [
                          const Text("Updated At: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          FormattedDateTimeText(isoString: todo['updated_at']),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// === CONTAINER 2: Description and Attachments ===
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xfffceabb), Color(0xfff8b500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(todo['description'] ?? "No description available"),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xfffceabb), Color(0xfff8b500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Attachments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                  await downloadFile(attachment['image_url'], attachment['file_name']);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// === CONTAINER 4: Notes or No Detail ===
              Container(
                padding: const EdgeInsets.all(16),
                width:double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xfffceabb), Color(0xfff8b500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (notes.isNotEmpty)
                      Column(
                        children: notes.map<Widget>((note) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white
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
                      )
                    else if (attachments.isEmpty && (todo['description'] ?? '').isEmpty)
                      const Text("No detail found.", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

Future<void> downloadFile(String url, String filename) async {
  try {
    final dir = Directory('/storage/emulated/0/Download');
    if (!await dir.exists()) await dir.create(recursive: true);

    final filePath = "${dir.path}/$filename";
    Dio dio = Dio();

    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          // print("Progress: ${(received / total * 100).toStringAsFixed(0)}%");
        }
      },
    );

    await _scanFile(filePath);
    Get.snackbar('Download Complete', 'Saved to: $filePath');
  } catch (e) {
    Get.snackbar('Download Failed', e.toString());
  }
}

Future<void> _scanFile(String filePath) async {
  try {
    const platform = MethodChannel('com.example.app/media');
    await platform.invokeMethod('scanFile', {'path': filePath});
  } on PlatformException catch (e) {
    print("Error scanning file: $e");
  }
}
