import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../All_custom_widgets/FormattedDateTime_custom.dart';
import 'package:path/path.dart' as p;

class TaskDetailPage extends StatelessWidget {
  final String taskname;
  final String status;
  final String description;
  final String deadline;
  final String priority;
  final String workType;
  final String createdBy;
  final String assignedTo;
  final String departmentName;
  final String? repeatUntil;
  final String createdAt;
  final String updatedAt;
  final List<dynamic> taskImages;
  final List<dynamic> notes;

  const TaskDetailPage({
    super.key,
    required this.taskname,
    required this.status,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.workType,
    required this.createdBy,
    required this.assignedTo,
    required this.departmentName,
    required this.createdAt,
    required this.updatedAt,
    required this.taskImages,
    required this.notes,
    this.repeatUntil,
    required todo,
  });

  String _format(String? value) {
    if (value == null) return '';
    return value.replaceAll('_', ' ').capitalizeFirst ?? '';
  }

  BoxDecoration _commonCardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xfffceabb), Color(0xfff8b500)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 4)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_format(taskname), style: const TextStyle(fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionContainer(title: "Task Info", children: [_buildTaskInfoSection()]),
            const SizedBox(height: 20),
            _buildSectionContainer(
              title: "Description",
              children: [
                Text(
                  description.isNotEmpty ? description : "No description found",
                  style: const TextStyle(fontSize: 15.5, height: 1.5, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionContainer(title: "Attachments", children: [_buildImageGallery(taskImages)]),
            const SizedBox(height: 20),
            notes.isNotEmpty
                ? _buildSectionContainer(
              title: "Notes",
              children: notes.map((note) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note['user']['name'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(note['content'] ?? ''),
                            const SizedBox(height: 4),
                            FormattedDateTimeText(
                              isoString: note['created_at'],
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            )
                : _buildSectionContainer(title: "Notes", children: [const Text("No notes available")]),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelChipRow(),
        const SizedBox(height: 16),
        _buildSingleField("Deadline", deadline),
        if (repeatUntil != null) _buildSingleField("Repeat Until", repeatUntil!),
        _buildSingleField("Created By", createdBy),
        _buildSingleField("Assigned To", assignedTo),
        _buildSingleField("Department", departmentName),
        _buildSingleField("Created At", createdAt),
        _buildSingleField("Updated At", updatedAt),
      ],
    );
  }

  Widget _buildSingleField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 15.5, color: Colors.black),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChipRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _pillChip("Status", _format(status), Colors.teal),
        _pillChip("Priority", _format(priority), Colors.deepOrange),
        _pillChip("Work Type", _format(workType), Colors.purple),
      ],
    );
  }

  Widget _pillChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.label_important, color: color, size: 16),
          const SizedBox(width: 4),
          Text("$label: $value", style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<dynamic> files) {
    if (files.isEmpty) {
      return const Text("No Attachments found.", style: TextStyle(color: Colors.black));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: files.map<Widget>((fileUrl) {
        try {
          final uri = Uri.parse(fileUrl);
          final filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'file';
          final extension = filename.contains('.') ? filename.split('.').last.toLowerCase() : 'unknown';

          // Check if the filename is extracted properly
          if (filename.isEmpty || filename == 'file') {
            return Text("Invalid file name.", style: TextStyle(color: Colors.red));
          }

          return GestureDetector(
            onTap: () async {
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
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes!)
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
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                          filename,
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "Extension: .$extension",
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.black),
                    onPressed: () => _downloadFile(fileUrl, filename),
                  ),
                ],
              ),
            ),
          );
        } catch (e) {
          // If there's an issue parsing the URL or filename, show an error
          return Text("Error extracting filename.", style: TextStyle(color: Colors.red));
        }
      }).toList(),
    );
  }


  void _downloadFile(String url, String filename) async {
    try {
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) await dir.create(recursive: true);

      final filePath = '${dir.path}/$filename';

      // Download the file
      await Dio().download(url, filePath);

      // Extract the filename from the file path
      String extractedFilename = p.basename(filePath);

      // Display the extracted filename in the snackbar
      Get.snackbar(
        "Download Complete",
        "File saved as: $extractedFilename",  // Show the extracted filename
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),  // Adjust duration for readability
      );
    } catch (e) {
      Get.snackbar(
        "Download Failed",
        "Could not download the file: $e",  // Show error details
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      );
    }
  }

  Widget _buildSectionContainer({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

