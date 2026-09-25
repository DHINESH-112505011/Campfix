import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/complaint.dart';
import '../../repositories/complaint_repository.dart';
import '../../widgets/campfix_complaint_card.dart';
import '../../widgets/campfix_empty_state.dart';
import 'admin_assign_staff_screen.dart';

class AdminComplaintListScreen extends StatefulWidget {
  const AdminComplaintListScreen({super.key});

  @override
  State<AdminComplaintListScreen> createState() => _AdminComplaintListScreenState();
}

class _AdminComplaintListScreenState extends State<AdminComplaintListScreen> {
  final ComplaintRepository _repository = ComplaintRepository();
  late Future<List<Complaint>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _complaintsFuture = _repository.getMyComplaints(); // admin scope returns all (backend-controlled)
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await _complaintsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaints')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Complaint>>(
            future: _complaintsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final complaints = snapshot.data!;
              if (complaints.isEmpty) {
                return ListView(
                  children: const [
                    CampFixEmptyState(
                      icon: Icons.inbox_rounded,
                      title: 'No complaints match your filters.',
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: complaints.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final c = complaints[index];
                  final needsAssignment = c.status == 'SUBMITTED' ||
                      c.status == 'AI_CLASSIFIED' ||
                      c.status == 'ADMIN_REVIEW';
                  final isAssignedAlready =
                      c.status == 'ASSIGNED' || c.status == 'ACCEPTED' || c.status == 'IN_PROGRESS';

                  return CampFixComplaintCard(
                    complaint: c,
                    onTap: () async {
                      if (needsAssignment || isAssignedAlready) {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => AdminAssignStaffScreen(
                              complaint: c,
                              isReassign: isAssignedAlready,
                            ),
                          ),
                        );
                        if (result == true) _refresh();
                      }
                    },
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