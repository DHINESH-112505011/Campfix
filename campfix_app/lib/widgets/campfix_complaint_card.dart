import 'package:flutter/material.dart';
import '../core/theme/app_spacing.dart';
import '../models/complaint.dart';
import 'campfix_card.dart';
import 'campfix_status_chip.dart';
import 'campfix_priority_badge.dart';

class CampFixComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback? onTap;

  const CampFixComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
  });

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          Text(
            '📍 ${complaint.building} • ${complaint.room}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CampFixStatusChip(status: complaint.status),
              Text('Updated ${_timeAgo(complaint.updatedAt)}', style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}