import 'package:flutter/material.dart';

class ComplaintCategory {
  final String id;
  final String name;
  final IconData icon;

  const ComplaintCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  static const List<ComplaintCategory> defaults = [
    ComplaintCategory(id: 'electrical', name: 'Electrical', icon: Icons.electrical_services_rounded),
    ComplaintCategory(id: 'plumbing', name: 'Plumbing', icon: Icons.plumbing_rounded),
    ComplaintCategory(id: 'cleaning', name: 'Cleaning', icon: Icons.cleaning_services_rounded),
    ComplaintCategory(id: 'it', name: 'IT', icon: Icons.computer_rounded),
    ComplaintCategory(id: 'hostel', name: 'Hostel', icon: Icons.apartment_rounded),
    ComplaintCategory(id: 'other', name: 'Other', icon: Icons.more_horiz_rounded),
  ];
}