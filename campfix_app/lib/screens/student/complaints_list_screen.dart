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
  final ScrollController _scrollController = ScrollController();

  final List<Complaint> _complaints = [];
  ComplaintFilter _filter = const ComplaintFilter();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
    });
    try {
      final results = await _repository.getMyComplaints(filter: _filter);
      if (!mounted) return;
      setState(() {
        _complaints
          ..clear()
          ..addAll(results);
        _hasMore = results.length == _pageSize;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final results = await _repository.getMyComplaints(filter: _filter, page: nextPage);
      if (!mounted) return;
      setState(() {
        _complaints.addAll(results);
        _page = nextPage;
        _hasMore = results.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onSearchChanged(String value) {
    _filter = _filter.copyWith(search: value.isEmpty ? null : value);
    _loadInitial();
  }

  Future<void> _openFilters() async {
    final result = await showCampFixFilterSheet(context, _filter);
    if (result != null) {
      _filter = result;
      _loadInitial();
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
                onRefresh: _loadInitial,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _complaints.isEmpty
                        ? ListView(
                            children: [
                              CampFixEmptyState(
                                icon: Icons.inbox_rounded,
                                title: _filter.isEmpty
                                    ? "You haven't reported any campus problems yet."
                                    : 'No complaints match your filters.',
                              ),
                            ],
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            itemCount: _complaints.length + (_hasMore ? 1 : 0),
                            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              if (index >= _complaints.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              final c = _complaints[index];
                              return CampFixComplaintCard(
                                complaint: c,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ComplaintDetailsScreen(complaintId: c.id),
                                  ),
                                ),
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