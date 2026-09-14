import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';

/// Displays complaint status as a colored pill (icon + text, never color alone).
class CampFixStatusChip extends StatelessWidget {
  final String status;

  const CampFixStatusChip({super.key, required this.status});

  ({Color color, IconData icon}) _styleFor(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
      case 'AI_CLASSIFIED':
      case 'ADMIN_REVIEW':
        return (color: AppColors.info, icon: Icons.hourglass_top_rounded);
      case 'ASSIGNED':
      case 'ACCEPTED':
        return (color: AppColors.warning, icon: Icons.assignment_ind_rounded);
      case 'IN_PROGRESS':
        return (color: AppColors.accent, icon: Icons.build_rounded);
      case 'WORK_COMPLETED':
      case 'ADMIN_VERIFIED':
        return (color: AppColors.primary, icon: Icons.fact_check_rounded);
      case 'RESOLVED':
        return (color: AppColors.success, icon: Icons.check_circle_rounded);
      case 'REJECTED':
      case 'CANCELLED':
        return (color: AppColors.danger, icon: Icons.cancel_rounded);
      case 'ON_HOLD':
        return (color: AppColors.textTertiary, icon: Icons.pause_circle_rounded);
      case 'REOPENED':
        return (color: AppColors.warning, icon: Icons.replay_circle_filled_rounded);
      default:
        return (color: AppColors.textTertiary, icon: Icons.circle);
    }
  }

  String _labelFor(String status) {
    return status
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0]}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 13, color: style.color),
          const SizedBox(width: 5),
          Text(
            _labelFor(status),
            style: TextStyle(
              color: style.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}