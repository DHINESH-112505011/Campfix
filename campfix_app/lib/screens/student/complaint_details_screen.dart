import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../models/complaint.dart';
import '../../models/timeline_event.dart';
import '../../repositories/complaint_repository.dart';
import '../../widgets/campfix_card.dart';
import '../../widgets/campfix_status_chip.dart';
import '../../widgets/campfix_priority_badge.dart';
import '../../widgets/campfix_timeline.dart';
import '../../widgets/campfix_section_header.dart';
import '../../core/errors/app_exception.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  final ComplaintRepository _repository = ComplaintRepository();

  Complaint? _complaint;
  List<TimelineEvent> _timeline = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _repository.getComplaintById(widget.complaintId),
        _repository.getTimeline(widget.complaintId),
      ]);
      if (!mounted) return;
      setState(() {
        _complaint = results[0] as Complaint;
        _timeline = results[1] as List<TimelineEvent>;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_complaint?.complaintNumber ?? 'Complaint')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
              const SizedBox(height: AppSpacing.md),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              TextButton(onPressed: _loadData, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    final complaint = _complaint!;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CampFixStatusChip(status: complaint.status),
              CampFixPriorityBadge(priority: complaint.priority),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(complaint.title, style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(complaint.description, style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),

          CampFixCard(
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.textTertiary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${complaint.building} • ${complaint.room}',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          const CampFixSectionHeader(title: 'Timeline'),
          const SizedBox(height: AppSpacing.lg),
          if (_timeline.isEmpty)
            Text('No timeline events yet.', style: textTheme.bodyMedium)
          else
            CampFixTimeline(events: _timeline),
        ],
      ),
    );
  }
}