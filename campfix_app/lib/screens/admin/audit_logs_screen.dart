import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/errors/app_exception.dart';
import '../../models/audit_log_entry.dart';
import '../../repositories/audit_log_repository.dart';
import '../../widgets/campfix_card.dart';
import '../../widgets/campfix_empty_state.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final AuditLogRepository _repository = AuditLogRepository();
  late Future<List<AuditLogEntry>> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _future = _repository.getAuditLogs();
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await _future;
  }

  String _formatValue(Map<String, dynamic>? value) {
    if (value == null) return '-';
    return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour < 12 ? 'AM' : 'PM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<AuditLogEntry>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final message = snapshot.error is AppException
                    ? (snapshot.error as AppException).message
                    : 'Unable to load audit logs.';
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxxl),
                      child: Center(child: Text(message, textAlign: TextAlign.center)),
                    ),
                  ],
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final logs = snapshot.data!;
              if (logs.isEmpty) {
                return ListView(
                  children: const [
                    CampFixEmptyState(
                      icon: Icons.history_rounded,
                      title: 'No audit log entries yet.',
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: logs.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final textTheme = Theme.of(context).textTheme;

                  return CampFixCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                log.displayAction,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(_formatDate(log.createdAt), style: textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${log.entityType} • ${log.entityId.substring(0, 8)}...',
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        if (log.oldValue != null || log.newValue != null)
                          Text(
                            '${_formatValue(log.oldValue)} → ${_formatValue(log.newValue)}',
                            style: textTheme.bodyMedium,
                          ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'By: ${log.performedByName ?? 'Unknown'} (${log.performedByRole ?? '-'})',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
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