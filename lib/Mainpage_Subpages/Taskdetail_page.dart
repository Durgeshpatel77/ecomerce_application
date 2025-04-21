import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../All_custom_widgets/FormattedDateTime_custom.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskname;
  final String status;
  final String description;
  final String deadline;
  final String priority;
  final String workType;
  //final String repetition;
  final String createdBy;
  final String assignedTo;
  //final String subdepartments;
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
   // required this.repetition,
    required this.createdBy,
    required this.assignedTo,
    required this.departmentName,
    //required this.subdepartments,
    required this.createdAt,
    required this.updatedAt,
    required this.taskImages,
    required this.notes,
    this.repeatUntil, required todo,
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
        title: Text(
          _format(taskname),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionContainer(
              title: "Task Info",
              children: [_buildTaskInfoSection()],
            ),
            const SizedBox(height: 20),
            _buildSectionContainer(
              title: "Task Images",
              children: [_buildImageGallery(taskImages)],
            ),
            const SizedBox(height: 20),
            _buildSectionContainer(
              title: "Description",
              children: [
                Text(description,
                    style: const TextStyle(fontSize: 15.5, height: 1.5, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 20),
            if (notes.isNotEmpty)
              _buildSectionContainer(
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
              ),
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
        //_buildSingleField("Repetition", _format(repetition)),
        if (repeatUntil != null) _buildSingleField("Repeat Until", repeatUntil!),
        _buildSingleField("Created By", createdBy),
        _buildSingleField("Assigned To", assignedTo),
        _buildSingleField("Department", departmentName),
       // _buildSingleField("Subdepartment", subdepartments),
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

  Widget _buildImageGallery(List<dynamic> images) {
    if (images.isEmpty) {
      return const Text("No images available.", style: TextStyle(color: Colors.red));
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          // Check if images is a list of strings (URLs)
          final imageUrl = images[index]; // Assuming it's a String URL

          return GestureDetector(
            onTap: () => _showFullImage(context, imageUrl),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 130,
                  height: 130,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
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