import 'package:flutter/material.dart';
import '../core/theme/app_spacing.dart';
import '../models/complaint_filter.dart';
import 'campfix_button.dart';
import 'campfix_outlined_button.dart';

const _statuses = [
  'SUBMITTED', 'ADMIN_REVIEW', 'ASSIGNED', 'ACCEPTED',
  'IN_PROGRESS', 'WORK_COMPLETED', 'RESOLVED', 'REJECTED', 'CANCELLED',
];
const _priorities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

Future<ComplaintFilter?> showCampFixFilterSheet(BuildContext context, ComplaintFilter current) {
  return showModalBottomSheet<ComplaintFilter>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _FilterSheetContent(initial: current),
  );
}

class _FilterSheetContent extends StatefulWidget {
  final ComplaintFilter initial;
  const _FilterSheetContent({required this.initial});

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late ComplaintFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: textTheme.headlineMedium),
                TextButton(
                  onPressed: () => setState(() => _draft = const ComplaintFilter()),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Status', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _statuses.map((status) {
                final isSelected = _draft.status == status;
                return ChoiceChip(
                  label: Text(_label(status)),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    _draft = isSelected
                        ? _draft.copyWith(clearStatus: true)
                        : _draft.copyWith(status: status);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Priority', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _priorities.map((priority) {
                final isSelected = _draft.priority == priority;
                return ChoiceChip(
                  label: Text(priority),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    _draft = isSelected
                        ? _draft.copyWith(clearPriority: true)
                        : _draft.copyWith(priority: priority);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: CampFixOutlinedButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CampFixButton(
                    label: 'Apply Filters',
                    onPressed: () => Navigator.of(context).pop(_draft),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _label(String status) {
    return status
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0]}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}