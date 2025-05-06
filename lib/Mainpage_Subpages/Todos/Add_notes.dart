import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/Todos contoller/Add_notes_controller.dart';

class AddNotePage extends StatelessWidget {
  final String uuid;
  final TextEditingController noteController = TextEditingController();
  final AddNoteController controller = Get.put(AddNoteController());

  AddNotePage({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: noteController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Enter note...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                final content = noteController.text.trim();
                if (content.isNotEmpty) {
                  controller.submitNote(uuid, content);
                } else {
                  Get.snackbar("Warning", "Note cannot be empty");
                }
              },
              child: const Text("Submit Note"),
            )),
          ],
        ),
      ),
    );
  }
}
