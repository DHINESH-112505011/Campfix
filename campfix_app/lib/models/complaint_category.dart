import 'package:flutter/material.dart';

class ComplaintCategory {
  final String id;   // real UUID from Supabase
  final String name;
  final IconData icon;

  const ComplaintCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory ComplaintCategory.fromJson(Map<String, dynamic> json) {
    return ComplaintCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: _iconFor(json['icon'] as String?),
    );
  }

  static IconData _iconFor(String? key) {
    switch (key) {
      case 'electrical_services':
        return Icons.electrical_services_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'cleaning_services':
        return Icons.cleaning_services_rounded;
      case 'chair':
        return Icons.chair_rounded;
      case 'computer':
        return Icons.computer_rounded;
      case 'wc':
        return Icons.wc_rounded;
      case 'apartment':
        return Icons.apartment_rounded;
      case 'foundation':
        return Icons.foundation_rounded;
      case 'ac_unit':
        return Icons.ac_unit_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }
}