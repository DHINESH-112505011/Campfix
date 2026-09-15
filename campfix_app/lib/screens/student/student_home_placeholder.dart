import 'package:flutter/material.dart';

class StudentHomePlaceholder extends StatelessWidget {
  const StudentHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Home')),
      body: const Center(
        child: Text('Student dashboard coming in Phase 4'),
      ),
    );
  }
}