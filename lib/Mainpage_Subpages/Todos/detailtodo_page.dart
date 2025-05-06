import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../All_custom_widgets/FormattedDateTime_custom.dart';
import '../../Controller/Todos contoller/Add_notes_controller.dart';
import '../../Controller/Todos contoller/Delete_notes.dart';
import '../../Controller/Todos contoller/ttodo_controller.dart';
import 'Add_notes.dart';

class TodoDetailPage extends StatelessWidget {
  final String uuid;
  final String id;
  final Map<String, dynamic> todo;
  final List<Map<String, dynamic>> notes;

  const TodoDetailPage({Key? key, required this.id, required this.todo, required this.notes, required this.uuid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TodoController controller = Get.put(TodoController());
    final NoteController noteController = Get.put(NoteController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTodoDetail(id);
    });

    String _format(String? value) {
      if (value == null) return '';
      return value.replaceAll('_', ' ').capitalizeFirst ?? '';
    }
    Future<void> _deleteNote(int noteId) async {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('access_token') ?? '';

      await noteController.deleteNoteById(noteId, authToken);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Todo Details"),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Get.to(() => AddNotePage(uuid: uuid)); // Pass uuid to AddNotePage
        },
        child: const Icon(Icons.add, size: 32),
      ),
      backgroundColor: Colors.white,
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
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                    border: Border.all(color: Colors.black38,width: 1)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Task Info",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Title: ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                capitalize(todo['title'] ?? ''),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _pillChip1("Status", _format(todo['status']), Colors.teal),
                            _pillChip1("Priority", _format(todo['priority']), Colors.deepOrange),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (todo['due_date'] != null)
                      Row(
                        children: [
                          const Text(
                            "Deadline: ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FormattedDateTimeText(isoString: todo['due_date']),
                        ],
                      ),
                    if (todo['completed_at'] != null)
                      Row(
                        children: [
                          const Text(
                            "Completed At: ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FormattedDateTimeText(
                            isoString: todo['completed_at'],
                          ),
                        ],
                      ),
                    if (todo['created_at'] != null)
                      Row(
                        children: [
                          const Text(
                            "Created At: ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FormattedDateTimeText(isoString: todo['created_at']),
                        ],
                      ),
                    if (todo['updated_at'] != null)
                      Row(
                        children: [
                          const Text(
                            "Updated At: ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                    border: Border.all(color: Colors.black38,width: 1)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (todo['description'] != null && todo['description'].toString().trim().isNotEmpty)
                          ? todo['description']
                          : "No description found",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Column(
                children: [
                  /// Attachments Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                        border: Border.all(color: Colors.black38,width: 1)
                    ),
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Attachments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (attachments != null && attachments.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: attachments.map<Widget>((attachment) {
                              final fileUrl = attachment['image_url'] ?? '';
                              final fileName = attachment['file_name'] ?? 'Unknown';
                              final fileType = attachment['file_type']?.toLowerCase() ?? 'unknown';

                              final uri = Uri.parse(fileUrl);
                              final extension = uri.pathSegments.isNotEmpty
                                  ? uri.pathSegments.last.split('.').last.toLowerCase()
                                  : 'unknown';

                              return GestureDetector(
                                onTap: () {
                                  if (['jpg', 'jpeg', 'png'].contains(extension)) {
                                    Get.dialog(
                                      Dialog(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          child: Image.network(
                                            fileUrl,
                                            fit: BoxFit.contain,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return SizedBox(
                                                height: 300,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                        (loadingProgress.expectedTotalBytes!)
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) => const Center(
                                              child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (extension == 'pdf') {
                                    Get.dialog(
                                      Dialog(
                                        child: SizedBox(
                                          width: 300,
                                          height: 400,
                                          child: SfPdfViewer.network(fileUrl),
                                        ),
                                      ),
                                    );
                                  } else {
                                    Get.snackbar(
                                      "Preview not supported",
                                      "Cannot preview .$extension files.",
                                        backgroundColor: Colors.red,
                                        snackPosition: SnackPosition.BOTTOM,
                                        icon: Icon(Icons.cancel, size: 33,color: Colors.white,),
                                        duration: Duration(seconds: 2),
                                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),  // Custom padding
                                        colorText: Colors.white
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(width: 1,color: Colors.black26),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.attach_file, color: Colors.black87),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fileName,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "Extension: .$extension",
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.download_rounded, color: Colors.black),
                                        onPressed: () async {
                                          await downloadFile(fileUrl, fileName);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Text(
                            "No attachment found",
                            style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                          ),
                      ],
                    ),
                  ),

                  /// Equal vertical spacing
                  const SizedBox(height: 20),

                  /// Notes Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                      border: Border.all(color: Colors.black38,width: 1)
                    ),
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (notes.isNotEmpty)
                          Column(
                            children: notes.map<Widget>((note) {
                              final content = note['content'] ?? '';
                              final email = note['user']['email'] ?? '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1,color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      capitalizeFirst(content),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          capitalizeFirst(email),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Spacer(),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            Get.defaultDialog(
                                              backgroundColor: Colors.white,

                                              title: "Delete Note",
                                              middleText: "Are you sure you want to delete this note?",
                                              textCancel: "Cancel",
                                              textConfirm: "Delete",

                                              confirmTextColor: Colors.white,
                                              buttonColor: Colors.red,
                                              onConfirm: () async {
                                                Get.back(); // Close dialog

                                                Get.dialog(
                                                  Center(child: CircularProgressIndicator()),
                                                  barrierDismissible: false,
                                                );

                                                final prefs = await SharedPreferences.getInstance();
                                                final authToken = prefs.getString('access_token') ?? '';

                                                final success = await noteController.deleteNoteById(note['id'], authToken);

                                                Get.back(); // Close loading

                                                if (success) {
                                                  // Remove note from todoDetail
                                                  final notes = controller.todoDetail['notes'];
                                                  if (notes is List) {
                                                    notes.removeWhere((n) => n['id'] == note['id']);
                                                    controller.todoDetail['notes'] = notes;
                                                    controller.todoDetail.refresh(); // Notify UI
                                                  }
                                                } else {
                                                  Get.defaultDialog(
                                                    title: "Error",
                                                    middleText: "Failed to delete the note.",
                                                    textConfirm: "OK",
                                                    confirmTextColor: Colors.white,
                                                    buttonColor: Colors.red,
                                                    onConfirm: () => Get.back(),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    FormattedDateTimeText(
                                      isoString: note['created_at'],
                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Text(
                            "No notes found.",  // Display this when notes are empty
                            style: TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                ],
              )
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
    Get.snackbar('Download Complete', 'Saved to: $filePath',
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.check_circle, size: 33,color: Colors.white,),
        duration: Duration(seconds: 2),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),  // Custom padding
        colorText: Colors.white
    );
  } catch (e) {
    Get.snackbar('Download Failed', e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.cancel, size: 33,color: Colors.white,),
        duration: Duration(seconds: 2),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),  // Custom padding
        colorText: Colors.white
    );
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
String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
Widget _pillChip1(String label, String value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.label_important, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: color,
          ),
        ),
      ],
    ),
  );
}

String _format(String? input) {
  if (input == null || input.isEmpty) return '';
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

Widget _buildTodoLabelChips(Map<String, dynamic> todo) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Task Info",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _pillChip1("Status", _format(todo['status']), Colors.teal),
          _pillChip1("Priority", _format(todo['priority']), Colors.deepOrange),
        ],
      ),
    ],
  );
}
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}