import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/app_role.dart';
import '../../models/complaint.dart';
import '../../models/timeline_event.dart';
import '../../repositories/complaint_repository.dart';
import '../../widgets/campfix_card.dart';
import '../../widgets/campfix_status_chip.dart';
import '../../widgets/campfix_priority_badge.dart';
import '../../widgets/campfix_timeline.dart';
import '../../widgets/campfix_section_header.dart';
import '../../widgets/campfix_button.dart';
import '../../widgets/campfix_outlined_button.dart';
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
  bool _isActionInProgress = false;
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

  Future<void> _updateStatus(String newStatus, {String? confirmMessage}) async {
    if (confirmMessage != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: Text(confirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, Keep It'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Continue'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isActionInProgress = true);
    try {
      final updated = await _repository.updateStatus(widget.complaintId, newStatus);
      if (!mounted) return;
      setState(() {
        _complaint = updated;
        _isActionInProgress = false;
      });
      await _loadData(); // refresh timeline to show the new entry
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isActionInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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

          const SizedBox(height: AppSpacing.xxl),
          Builder(builder: (context) {
            final role = context.watch<AuthProvider>().currentRole;
            if (role == AppRole.admin || role == AppRole.superAdmin) {
              return Column(children: _buildAdminActions(complaint));
            }
            return Column(children: _buildStudentActions(complaint));
          }),
        ],
      ),
    );
  }

  List<Widget> _buildAdminActions(Complaint complaint) {
    final actions = <Widget>[];

    if (complaint.status == 'SUBMITTED' ||
        complaint.status == 'AI_CLASSIFIED' ||
        complaint.status == 'ADMIN_REVIEW') {
      actions.add(
        CampFixOutlinedButton(
          label: 'Reject Complaint',
          icon: Icons.block_rounded,
          onPressed: _isActionInProgress
              ? null
              : () => _updateStatus(
                    'REJECTED',
                    confirmMessage: 'Reject this complaint? This cannot be easily undone.',
                  ),
        ),
      );
    }

    if (complaint.status == 'WORK_COMPLETED') {
      actions.add(
        CampFixButton(
          label: 'Verify Work',
          onPressed: _isActionInProgress ? null : () => _updateStatus('ADMIN_VERIFIED'),
        ),
      );
    }

    if (complaint.status == 'ADMIN_VERIFIED') {
      if (actions.isNotEmpty) actions.add(const SizedBox(height: AppSpacing.sm));
      actions.add(
        CampFixButton(
          label: 'Resolve Complaint',
          onPressed: _isActionInProgress ? null : () => _updateStatus('RESOLVED'),
        ),
      );
    }

    return actions.isEmpty
        ? []
        : [
            for (int i = 0; i < actions.length; i++) ...[
              actions[i],
              if (i < actions.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ];
  }

  List<Widget> _buildStudentActions(Complaint complaint) {
    final isActive = !['RESOLVED', 'REJECTED', 'CANCELLED'].contains(complaint.status);
    final canCancel = isActive && complaint.status != 'IN_PROGRESS' && complaint.status != 'WORK_COMPLETED';
    final canReopen = complaint.status == 'RESOLVED';

    if (!canCancel && !canReopen) return [];

    return [
      if (canCancel)
        CampFixOutlinedButton(
          label: 'Cancel Complaint',
          icon: Icons.close_rounded,
          onPressed: _isActionInProgress
              ? null
              : () => _updateStatus(
                    'CANCELLED',
                    confirmMessage: 'Are you sure you want to cancel this complaint?',
                  ),
        ),
      if (canReopen)
        CampFixButton(
          label: 'Problem Still Exists - Reopen',
          onPressed: _isActionInProgress
              ? null
              : () => _updateStatus(
                    'REOPENED',
                    confirmMessage: 'This will reopen the complaint for admin review. Continue?',
                  ),
        ),
    ];
  }
}