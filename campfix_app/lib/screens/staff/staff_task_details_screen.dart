import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/errors/app_exception.dart';
import '../../models/complaint_assignment.dart';
import '../../repositories/assignment_repository.dart';
import '../../widgets/campfix_card.dart';
import '../../widgets/campfix_status_chip.dart';
import '../../widgets/campfix_priority_badge.dart';
import '../../widgets/campfix_button.dart';
import '../../widgets/campfix_text_field.dart';

class StaffTaskDetailsScreen extends StatefulWidget {
  final ComplaintAssignment assignment;

  const StaffTaskDetailsScreen({super.key, required this.assignment});

  @override
  State<StaffTaskDetailsScreen> createState() => _StaffTaskDetailsScreenState();
}

class _StaffTaskDetailsScreenState extends State<StaffTaskDetailsScreen> {
  final AssignmentRepository _repository = AssignmentRepository();
  final TextEditingController _notesController = TextEditingController();
  late ComplaintAssignment _assignment;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _assignment = widget.assignment;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(Future<ComplaintAssignment> Function() action) async {
    setState(() => _isProcessing = true);
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() {
        _assignment = updated;
        _isProcessing = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaint = _assignment.complaint!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(complaint.complaintNumber)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CampFixStatusChip(status: _assignment.status),
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
            const SizedBox(height: AppSpacing.xxl),
            _buildActionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    switch (_assignment.status) {
      case 'ASSIGNED':
        return CampFixButton(
          label: 'Accept Assignment',
          isLoading: _isProcessing,
          onPressed: () => _handleAction(() => _repository.accept(_assignment.id)),
        );
      case 'ACCEPTED':
        return CampFixButton(
          label: 'Start Work',
          isLoading: _isProcessing,
          onPressed: () => _handleAction(() => _repository.startWork(_assignment.id)),
        );
      case 'IN_PROGRESS':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampFixTextField(
              label: 'Work Notes (optional)',
              hint: 'Describe what was done...',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            CampFixButton(
              label: 'Mark Work Completed',
              isLoading: _isProcessing,
              onPressed: () => _handleAction(
                () => _repository.markCompleted(_assignment.id, notes: _notesController.text.trim()),
              ),
            ),
          ],
        );
      case 'COMPLETED':
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text('Work completed. Awaiting admin verification.'),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}