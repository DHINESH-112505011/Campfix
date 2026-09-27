import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/errors/app_exception.dart';
import '../../models/analytics_data.dart';
import '../../repositories/dashboard_repository.dart';
import '../../widgets/campfix_stat_card.dart';
import '../../widgets/campfix_chart_card.dart';
import '../../widgets/campfix_card.dart';
import '../../widgets/campfix_section_header.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final DashboardRepository _repository = DashboardRepository();
  late Future<AnalyticsData> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _future = _repository.getAnalytics();
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<AnalyticsData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final message = snapshot.error is AppException
                    ? (snapshot.error as AppException).message
                    : 'Unable to load analytics.';
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

              final data = snapshot.data!;
              final textTheme = Theme.of(context).textTheme;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('Performance Overview', style: textTheme.headlineMedium),
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
                        value: '${data.avgResolutionTimeHours.toStringAsFixed(1)}h',
                        label: 'Avg. Resolution Time',
                        icon: Icons.timer_outlined,
                        color: AppColors.info,
                      ),
                      CampFixStatCard(
                        value: '${data.reopenedCount}',
                        label: 'Reopened',
                        icon: Icons.replay_circle_filled_rounded,
                        color: AppColors.warning,
                      ),
                      CampFixStatCard(
                        value: data.satisfaction.averageRating.toStringAsFixed(1),
                        label: 'Avg. Rating',
                        icon: Icons.star_rounded,
                        color: AppColors.warning,
                      ),
                      CampFixStatCard(
                        value: '${data.satisfaction.resolvedSuccessfullyPercent}%',
                        label: 'Resolved Successfully',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                    ],
                  ),

                  if (data.satisfaction.totalFeedback == 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No feedback submitted yet.',
                      style: textTheme.bodySmall,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  CampFixChartCard(title: 'Complaints by Category', data: data.byCategory),
                  const SizedBox(height: AppSpacing.lg),
                  CampFixChartCard(title: 'Complaints by Department', data: data.byDepartment),
                  const SizedBox(height: AppSpacing.lg),
                  CampFixChartCard(title: 'Complaints by Status', data: data.byStatus),

                  const SizedBox(height: AppSpacing.xl),
                  const CampFixSectionHeader(title: 'Staff Performance'),
                  const SizedBox(height: AppSpacing.md),
                  if (data.staffPerformance.isEmpty)
                    CampFixCard(
                      child: Text('No ratings yet.', style: textTheme.bodyMedium),
                    )
                  else
                    ...data.staffPerformance.map(
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
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${s.averageRating.toStringAsFixed(1)} (${s.totalRatings})',
                                    style: textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ],
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