import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TodoDetailPage extends StatelessWidget {
  final dynamic todo;

  const TodoDetailPage({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final data = todo['data'];
    final List attachments = data['attachments'] ?? [];
    final List notes = data['notes'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(data['title'] ?? 'Todo Detail'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _infoTile("Description", data['description']),
            _infoTile("Due Date", data['due_date']),
            _infoTile("Priority", data['priority']),
            _infoTile("Status", data['status']),
            _infoTile("Time Remaining", data['time_remaining']),
            const SizedBox(height: 20),
            Text("📎 Attachments", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...attachments.map((file) => _attachmentTile(file)),
            const SizedBox(height: 20),
            Text("🗒️ Notes", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...notes.map((note) => _noteTile(note)),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? '')),
        ],
      ),
    );
  }

  Widget _attachmentTile(dynamic file) {
    final fileType = file['file_type'];
    final fileName = file['file_name'];
    final fileUrl = file['image_url'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: fileType == 'png' || fileType == 'jpg' || fileType == 'jpeg'
            ? Image.network(fileUrl, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.insert_drive_file, color: Colors.blue),
        title: Text(fileName),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () async {
            final Uri url = Uri.parse(fileUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
    );
  }

  Widget _noteTile(dynamic note) {
    final content = note['content'];
    final user = note['user'];
    final userName = user['name'];
    final profileUrl = user['profile_photo_url'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(profileUrl),
        ),
        title: Text(userName),
        subtitle: Text(content),
      ),
    );
  }
}
