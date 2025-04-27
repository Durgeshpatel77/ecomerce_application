import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/Todos contoller/Add_notes_controller.dart';

class AddNotes extends StatelessWidget {
  final String uuid; // Pass the task UUID
  final String authToken; // Pass the user's auth token

  AddNotes({super.key, required this.uuid, required this.authToken});

  final AddNotesController controller = Get.put(AddNotesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField for adding or editing the note
            TextField(
              controller: controller.notecontroller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter your note here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Button to submit the note
            ElevatedButton.icon(
              onPressed: () {
                controller.submitNotes(uuid, authToken); // Call the method to submit the note
              },
              icon: const Icon(Icons.send),
              label: const Text("Submit Note"),
            ),
            Obx(() {
              return controller.isLoading.value
                  ? const CircularProgressIndicator() // Show loading spinner when API is processing
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
