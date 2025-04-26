import 'package:flutter/material.dart';

class AddNotes extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();

  AddNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter your note here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // No functionality here, just UI
              },
              icon: const Icon(Icons.send),
              label: const Text("Submit Note"),
            ),
          ],
        ),
      ),
    );
  }
}
