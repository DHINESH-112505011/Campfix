import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../models/complaint.dart';
import '../../models/complaint_category.dart';
import '../../repositories/complaint_repository.dart';
import '../../repositories/category_repository.dart';
import '../../widgets/campfix_card.dart';
import '../../widgets/campfix_stat_card.dart';
import '../../widgets/campfix_complaint_card.dart';
import '../../widgets/campfix_section_header.dart';
import '../../widgets/campfix_category_chip.dart';
import '../../widgets/campfix_empty_state.dart';
import '../../core/theme/app_colors.dart';
import 'report/report_wizard_screen.dart';
import 'complaint_details_screen.dart';
import 'complaints_list_screen.dart';

class StudentHomePlaceholder extends StatefulWidget {
  const StudentHomePlaceholder({super.key});

  @override
  State<StudentHomePlaceholder> createState() => _StudentHomePlaceholderState();
}

class _StudentHomePlaceholderState extends State<StudentHomePlaceholder> {
  final ComplaintRepository _repository = ComplaintRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  late Future<List<Complaint>> _complaintsFuture;
  late Future<({int total, int active, int resolved})> _statsFuture;
  late Future<List<ComplaintCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _complaintsFuture = _repository.getMyComplaints();
    _statsFuture = _repository.getMyStats();
    _categoriesFuture = _categoryRepository.getCategories();
  }

  Future<void> _onRefresh() async {
    setState(_loadData);
    await Future.wait([_complaintsFuture, _statsFuture]);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().currentUserEmail ?? 'Student';
    final firstName = email.split('@').first;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Header
              Text('${_greeting()}, $firstName 👋', style: textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text("Let's keep your campus running smoothly.", style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),

              // Primary CTA
                            CampFixCard(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReportWizardScreen()),
                  );
                  if (mounted) _onRefresh();

                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Report a Problem', style: textTheme.titleMedium),
                          Text('Takes less than a minute', style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiary),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Stats
              FutureBuilder<({int total, int active, int resolved})>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 90,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final stats = snapshot.data!;
                  return Row(
                    children: [
                      Expanded(
                        child: CampFixStatCard(
                          value: '${stats.total}',
                          label: 'Total',
                          icon: Icons.list_alt_rounded,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: CampFixStatCard(
                          value: '${stats.active}',
                          label: 'Active',
                          icon: Icons.hourglass_top_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: CampFixStatCard(
                          value: '${stats.resolved}',
                          label: 'Resolved',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick categories
              const CampFixSectionHeader(title: 'Quick Categories'),
              const SizedBox(height: AppSpacing.md),
               FutureBuilder<List<ComplaintCategory>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(height: 88);
                  }
                  final categories = snapshot.data!;
                  return SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return CampFixCategoryChip(
                          category: category,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReportWizardScreen(initialCategoryId: category.id),
                              ),
                            );
                            if (mounted) _onRefresh();
                          },
                        );
                      },
                    ),
                  );
                },
              ),  
              const SizedBox(height: AppSpacing.xl),

              // Recent complaints
              CampFixSectionHeader(
                title: 'Recent Complaints',
                actionLabel: 'View All',
                onActionTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ComplaintsListScreen()),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              FutureBuilder<List<Complaint>>(
                future: _complaintsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final complaints = snapshot.data!;
                  if (complaints.isEmpty) {
                    return const CampFixEmptyState(
                      icon: Icons.inbox_rounded,
                      title: "You haven't reported any campus problems yet.",
                      actionLabel: 'Report a Problem',
                    );
                  }
                  return Column(
                    children: complaints
                        .map(
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
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}