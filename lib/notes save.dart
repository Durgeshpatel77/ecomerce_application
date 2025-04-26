import 'package:flutter/material.dart';

class Notessave extends StatelessWidget {
  final String noteContent;

  const Notessave({super.key, required this.noteContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Note")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          noteContent,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
