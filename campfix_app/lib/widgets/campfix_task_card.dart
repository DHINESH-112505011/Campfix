import 'package:flutter/material.dart';
import '../core/theme/app_spacing.dart';
import '../models/complaint_assignment.dart';
import 'campfix_card.dart';
import 'campfix_status_chip.dart';
import 'campfix_priority_badge.dart';

class CampFixTaskCard extends StatelessWidget {
  final ComplaintAssignment assignment;
  final VoidCallback? onTap;

  const CampFixTaskCard({super.key, required this.assignment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final complaint = assignment.complaint;
    final textTheme = Theme.of(context).textTheme;

    if (complaint == null) return const SizedBox.shrink();

    return CampFixCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(complaint.complaintNumber, style: textTheme.labelLarge),
              CampFixPriorityBadge(priority: complaint.priority),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(complaint.title, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text('📍 ${complaint.building} • ${complaint.room}', style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          CampFixStatusChip(status: assignment.status),
        ],
      ),
    );
  }
}