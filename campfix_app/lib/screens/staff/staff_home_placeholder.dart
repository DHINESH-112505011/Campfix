import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../models/complaint_assignment.dart';
import '../../repositories/assignment_repository.dart';
import '../../widgets/campfix_stat_card.dart';
import '../../widgets/campfix_task_card.dart';
import '../../widgets/campfix_section_header.dart';
import '../../widgets/campfix_empty_state.dart';
import '../../core/theme/app_colors.dart';
import 'staff_task_details_screen.dart';

class StaffHomePlaceholder extends StatefulWidget {
  const StaffHomePlaceholder({super.key});

  @override
  State<StaffHomePlaceholder> createState() => _StaffHomePlaceholderState();
}

class _StaffHomePlaceholderState extends State<StaffHomePlaceholder> {
  final AssignmentRepository _repository = AssignmentRepository();
  late Future<List<ComplaintAssignment>> _assignmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _assignmentsFuture = _repository.getMyAssignments();
  }

  Future<void> _onRefresh() async {
    setState(_loadData);
    await _assignmentsFuture;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().currentUserEmail ?? 'Staff';
    final firstName = email.split('@').first;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: FutureBuilder<List<ComplaintAssignment>>(
            future: _assignmentsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final assignments = snapshot.data!;
              final assigned = assignments.where((a) => a.status == 'ASSIGNED').length;
              final inProgress = assignments.where((a) => a.status == 'IN_PROGRESS').length;
              final completed = assignments.where((a) => a.status == 'COMPLETED').length;
              final activeTasks = assignments
                  .where((a) => a.status != 'COMPLETED' && a.status != 'REJECTED')
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('${_greeting()}, $firstName', style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text("Here's what needs your attention today.", style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    children: [
                      Expanded(
                        child: CampFixStatCard(
                          value: '$assigned',
                          label: 'Assigned',
                          icon: Icons.assignment_ind_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: CampFixStatCard(
                          value: '$inProgress',
                          label: 'In Progress',
                          icon: Icons.build_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: CampFixStatCard(
                          value: '$completed',
                          label: 'Completed',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  const CampFixSectionHeader(title: "Today's Tasks"),
                  const SizedBox(height: AppSpacing.md),
                  if (activeTasks.isEmpty)
                    const CampFixEmptyState(
                      icon: Icons.task_alt_rounded,
                      title: 'No tasks assigned.',
                    )
                  else
                    ...activeTasks.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: CampFixTaskCard(
                          assignment: a,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StaffTaskDetailsScreen(assignment: a),
                              ),
                            );
                            if (mounted) _onRefresh();
                          },
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