import 'package:flutter/material.dart';

class StaffHomePlaceholder extends StatelessWidget {
  const StaffHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Dashboard')),
      body: const Center(
        child: Text('Staff dashboard coming in Phase 11'),
      ),
    );
  }
}