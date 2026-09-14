import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';

/// LOW / MEDIUM / HIGH / CRITICAL badge - icon + text, never color alone.
class CampFixPriorityBadge extends StatelessWidget {
  final String priority;

  const CampFixPriorityBadge({super.key, required this.priority});

  ({Color color, IconData icon}) _styleFor(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return (color: AppColors.priorityLow, icon: Icons.south_rounded);
      case 'MEDIUM':
        return (color: AppColors.priorityMedium, icon: Icons.remove_rounded);
      case 'HIGH':
        return (color: AppColors.priorityHigh, icon: Icons.north_rounded);
      case 'CRITICAL':
        return (color: AppColors.priorityCritical, icon: Icons.warning_rounded);
      default:
        return (color: AppColors.textTertiary, icon: Icons.circle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: style.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 13, color: style.color),
          const SizedBox(width: 5),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              color: style.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}