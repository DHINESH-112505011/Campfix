import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/complaint_draft.dart';
import '../../../widgets/campfix_button.dart';
import '../../../widgets/campfix_card.dart';
import '../../../widgets/campfix_priority_badge.dart';
import '../../../widgets/campfix_step_progress.dart';

class ReportStep4Screen extends StatefulWidget {
  final ComplaintDraft draft;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;

  const ReportStep4Screen({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<ReportStep4Screen> createState() => _ReportStep4ScreenState();
}

class _ReportStep4ScreenState extends State<ReportStep4Screen> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Simulated AI classification (real model wired in Phase 15).
    // Deterministic-ish mock based on category, so it feels believable.
    final draft = widget.draft;
    draft.aiCategory = draft.categoryName;
    draft.aiPriority = _mockPriorityFor(draft.categoryName ?? '');
    draft.aiConfidence = 0.88 + (draft.title.length % 10) / 100;
  }

  String _mockPriorityFor(String category) {
    switch (category) {
      case 'Electrical':
        return 'HIGH';
      case 'Civil':
        return 'CRITICAL';
      case 'Furniture':
        return 'LOW';
      default:
        return 'MEDIUM';
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    await widget.onSubmit();
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final draft = widget.draft;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Problem'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CampFixStepProgress(currentStep: 3, totalSteps: 4),
              const SizedBox(height: AppSpacing.xl),
              Text('Review & Submit', style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('Double-check the details before submitting.', style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView(
                  children: [
                    CampFixCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(draft.categoryName ?? '', style: textTheme.labelLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text(draft.title, style: textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(draft.description, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CampFixCard(
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.textTertiary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              [
                                draft.building,
                                if (draft.block.isNotEmpty) 'Block ${draft.block}',
                                if (draft.floor.isNotEmpty) '${draft.floor} Floor',
                                draft.room,
                              ].where((s) => s.isNotEmpty).join(' • '),
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (draft.imageFile != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          draft.imageFile!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    CampFixCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 18),
                              const SizedBox(width: AppSpacing.xs),
                              Text('AI Analysis', style: textTheme.labelLarge),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Predicted Category', style: textTheme.bodyMedium),
                              Text(draft.aiCategory ?? '-', style: textTheme.labelLarge),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Predicted Priority', style: textTheme.bodyMedium),
                              CampFixPriorityBadge(priority: draft.aiPriority ?? 'MEDIUM'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Confidence', style: textTheme.bodyMedium),
                              Text(
                                '${((draft.aiConfidence ?? 0) * 100).toStringAsFixed(0)}%',
                                style: textTheme.labelLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CampFixButton(
                label: 'Submit Complaint',
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}