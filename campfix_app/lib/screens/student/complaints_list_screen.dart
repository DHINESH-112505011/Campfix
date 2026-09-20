import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/complaint.dart';
import '../../repositories/complaint_repository.dart';
import '../../widgets/campfix_complaint_card.dart';
import '../../widgets/campfix_empty_state.dart';
import 'complaint_details_screen.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  final ComplaintRepository _repository = ComplaintRepository();
  late Future<List<Complaint>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _repository.getMyComplaints();
  }

  Future<void> _refresh() async {
    setState(() {
      _complaintsFuture = _repository.getMyComplaints();
    });
    await _complaintsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
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
                      title: "You haven't reported any campus problems yet.",
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
                  return CampFixComplaintCard(
                    complaint: c,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ComplaintDetailsScreen(complaintId: c.id),
                      ),
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