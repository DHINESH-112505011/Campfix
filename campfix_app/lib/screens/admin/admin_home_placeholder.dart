import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/errors/app_exception.dart';
import '../../models/dashboard_stats.dart';
import '../../repositories/dashboard_repository.dart';
import '../../widgets/campfix_stat_card.dart';
import '../../widgets/campfix_chart_card.dart';
import '../../widgets/campfix_section_header.dart';
import '../../widgets/campfix_complaint_card.dart';
import '../../widgets/campfix_card.dart';
import '../student/complaint_details_screen.dart';

class AdminHomePlaceholder extends StatefulWidget {
  const AdminHomePlaceholder({super.key});

  @override
  State<AdminHomePlaceholder> createState() => _AdminHomePlaceholderState();
}

class _AdminHomePlaceholderState extends State<AdminHomePlaceholder> {
  final DashboardRepository _repository = DashboardRepository();
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _statsFuture = _repository.getAdminDashboard();
  }

  Future<void> _onRefresh() async {
    setState(_loadData);
    await _statsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: FutureBuilder<DashboardStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final message = snapshot.error is AppException
                    ? (snapshot.error as AppException).message
                    : 'Unable to load dashboard.';
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

              final stats = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('Good Morning, Admin', style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Campus Overview', style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.6,
                    children: [
                      CampFixStatCard(
                        value: '${stats.total}',
                        label: 'Total',
                        icon: Icons.list_alt_rounded,
                        color: AppColors.info,
                      ),
                      CampFixStatCard(
                        value: '${stats.active}',
                        label: 'Active',
                        icon: Icons.hourglass_top_rounded,
                        color: AppColors.warning,
                      ),
                      CampFixStatCard(
                        value: '${stats.resolved}',
                        label: 'Resolved',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                      CampFixStatCard(
                        value: '${stats.critical}',
                        label: 'Critical',
                        icon: Icons.warning_rounded,
                        color: AppColors.danger,
                      ),
                    ],
                  ),

                  if (stats.critical > 0) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.priority_high_rounded, color: AppColors.danger),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${stats.critical} critical complaint${stats.critical == 1 ? '' : 's'} need immediate attention',
                              style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  CampFixChartCard(title: 'Complaints by Category', data: stats.byCategory),
                  const SizedBox(height: AppSpacing.lg),
                  CampFixChartCard(title: 'Complaints by Status', data: stats.byStatus),

                  const SizedBox(height: AppSpacing.xl),
                  const CampFixSectionHeader(title: 'Staff Workload'),
                  const SizedBox(height: AppSpacing.md),
                  if (stats.staffWorkload.isEmpty)
                    CampFixCard(
                      child: Text('No active assignments.', style: textTheme.bodyMedium),
                    )
                  else
                    ...stats.staffWorkload.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: CampFixCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.fullName, style: textTheme.titleMedium),
                                  if (s.specialization != null)
                                    Text(s.specialization!, style: textTheme.bodySmall),
                                ],
                              ),
                              Text(
                                '${s.activeAssignments} active job${s.activeAssignments == 1 ? '' : 's'}',
                                style: textTheme.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl),
                  const CampFixSectionHeader(title: 'Recent Complaints'),
                  const SizedBox(height: AppSpacing.md),
                  ...stats.recentComplaints.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: CampFixComplaintCard(
                        complaint: c,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ComplaintDetailsScreen(complaintId: c.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}