import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/complaint.dart';
import '../../models/complaint_filter.dart';
import '../../repositories/complaint_repository.dart';
import '../../widgets/campfix_complaint_card.dart';
import '../../widgets/campfix_empty_state.dart';
import '../../widgets/campfix_search_bar.dart';
import '../../widgets/campfix_filter_bottom_sheet.dart';
import 'complaint_details_screen.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  final ComplaintRepository _repository = ComplaintRepository();
  late Future<List<Complaint>> _complaintsFuture;
  ComplaintFilter _filter = const ComplaintFilter();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _complaintsFuture = _repository.getMyComplaints(filter: _filter);
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await _complaintsFuture;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _filter = _filter.copyWith(search: value.isEmpty ? null : value);
      _loadData();
    });
  }

  Future<void> _openFilters() async {
    final result = await showCampFixFilterSheet(context, _filter);
    if (result != null) {
      setState(() {
        _filter = result;
        _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: CampFixSearchBar(
                onChanged: _onSearchChanged,
                onFilterTap: _openFilters,
                activeFilterCount: _filter.activeCount,
              ),
            ),
            Expanded(
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
                        children: [
                          CampFixEmptyState(
                            icon: Icons.inbox_rounded,
                            title: _filter.isEmpty
                                ? "You haven't reported any campus problems yet."
                                : 'No complaints match your filters.',
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
          ],
        ),
      ),
    );
  }
}