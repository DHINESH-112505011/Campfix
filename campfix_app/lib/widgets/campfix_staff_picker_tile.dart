import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/staff_member.dart';
import 'campfix_card.dart';

class CampFixStaffPickerTile extends StatelessWidget {
  final StaffMember staff;
  final bool isSelected;
  final VoidCallback onTap;

  const CampFixStaffPickerTile({
    super.key,
    required this.staff,
    required this.isSelected,
    required this.onTap,
  });

  Color _workloadColor(int count) {
    if (count == 0) return AppColors.success;
    if (count <= 2) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CampFixCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.fullName, style: textTheme.titleMedium),
                if (staff.specialization != null)
                  Text(staff.specialization!, style: textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _workloadColor(staff.activeAssignments).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${staff.activeAssignments} active job${staff.activeAssignments == 1 ? '' : 's'}',
              style: TextStyle(
                color: _workloadColor(staff.activeAssignments),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
            color: isSelected ? AppColors.primary : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}