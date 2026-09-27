import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/notification_item.dart';
import '../../repositories/notification_repository.dart';
import '../../widgets/campfix_notification_tile.dart';
import '../../widgets/campfix_empty_state.dart';
import '../student/complaint_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repository = NotificationRepository();
  late Future<({List<NotificationItem> items, int unreadCount})> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _future = _repository.getMyNotifications();
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await _future;
  }

  Future<void> _handleTap(NotificationItem notification) async {
    if (!notification.isRead) {
      await _repository.markAsRead(notification.id);
    }
    if (!mounted) return;
    if (notification.relatedComplaintId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ComplaintDetailsScreen(complaintId: notification.relatedComplaintId!),
        ),
      );
    }
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await _repository.markAllAsRead();
              _refresh();
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<({List<NotificationItem> items, int unreadCount})>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data!.items;
              if (items.isEmpty) {
                return ListView(
                  children: const [
                    CampFixEmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications yet.',
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = items[index];
                  return CampFixNotificationTile(
                    notification: notification,
                    onTap: () => _handleTap(notification),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}