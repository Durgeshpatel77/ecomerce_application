import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/Todos controller/Add_notes_controller.dart';
import '../../Controller/Todos controller/Ttodostatus_controller.dart';

class AddNotes extends StatelessWidget {
  final String uuid; // Pass the task UUID
  final String authToken; // Pass the user's auth token

  AddNotes({super.key, required this.uuid, required this.authToken});

  final AddNotesController controller = Get.put(AddNotesController());
  final statusController = Get.find<TodoStatusController>();

  // Create FocusNode for managing focus
  final FocusNode focusNode = FocusNode();

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
              focusNode: focusNode, // Set focus node
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
                controller.submitNotes(
                  uuid,
                  authToken,
                ); // Call the method to submit the note
              },
              label: const Text(
                "Submit Note",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                elevation: 5,
              ),
            ),
            Obx(() {
              return controller.isLoading.value
                  ? const CircularProgressIndicator() // Show loading spinner
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
