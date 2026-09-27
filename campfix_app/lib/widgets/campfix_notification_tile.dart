import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/notification_item.dart';

class CampFixNotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;

  const CampFixNotificationTile({super.key, required this.notification, this.onTap});

  IconData _iconFor(String type) {
    switch (type) {
      case 'COMPLAINT_SUBMITTED':
        return Icons.send_rounded;
      case 'COMPLAINT_ASSIGNED':
      case 'NEW_ASSIGNMENT':
        return Icons.assignment_ind_rounded;
      case 'WORK_STARTED':
        return Icons.build_rounded;
      case 'COMPLAINT_COMPLETED':
        return Icons.check_circle_outline_rounded;
      case 'COMPLAINT_RESOLVED':
        return Icons.check_circle_rounded;
      case 'COMPLAINT_REOPENED':
        return Icons.replay_circle_filled_rounded;
      case 'ASSIGNMENT_CHANGED':
        return Icons.swap_horiz_rounded;
      case 'URGENT_COMPLAINT':
      case 'CRITICAL_COMPLAINT':
        return Icons.warning_rounded;
      case 'NEW_COMPLAINT':
        return Icons.inbox_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'URGENT_COMPLAINT':
      case 'CRITICAL_COMPLAINT':
        return AppColors.danger;
      case 'COMPLAINT_RESOLVED':
        return AppColors.success;
      case 'WORK_STARTED':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _colorFor(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        color: notification.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconFor(notification.type), color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(notification.message, style: textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(_timeAgo(notification.createdAt), style: textTheme.bodySmall),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}