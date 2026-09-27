import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/errors/app_exception.dart';
import '../../repositories/feedback_repository.dart';
import '../../widgets/campfix_star_rating.dart';
import '../../widgets/campfix_button.dart';
import '../../widgets/campfix_text_field.dart';

class ComplaintFeedbackScreen extends StatefulWidget {
  final String complaintId;
  final String complaintNumber;

  const ComplaintFeedbackScreen({
    super.key,
    required this.complaintId,
    required this.complaintNumber,
  });

  @override
  State<ComplaintFeedbackScreen> createState() => _ComplaintFeedbackScreenState();
}

class _ComplaintFeedbackScreenState extends State<ComplaintFeedbackScreen> {
  final FeedbackRepository _repository = FeedbackRepository();
  final TextEditingController _commentController = TextEditingController();

  int _rating = 0;
  bool? _resolvedSuccessfully;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _rating > 0 && _resolvedSuccessfully != null;

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);
    try {
      await _repository.submitFeedback(
        complaintId: widget.complaintId,
        rating: _rating,
        resolvedSuccessfully: _resolvedSuccessfully!,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Experience')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ListView(
            children: [
              Text(widget.complaintNumber, style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'How was your experience?',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              CampFixStarRating(
                rating: _rating,
                onChanged: (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Was the issue properly fixed?', style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _YesNoOption(
                      label: 'Yes',
                      isSelected: _resolvedSuccessfully == true,
                      onTap: () => setState(() => _resolvedSuccessfully = true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _YesNoOption(
                      label: 'No',
                      isSelected: _resolvedSuccessfully == false,
                      onTap: () => setState(() => _resolvedSuccessfully = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              CampFixTextField(
                label: 'Additional Comments (optional)',
                hint: 'Tell us more about your experience...',
                controller: _commentController,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xxl),
              CampFixButton(
                label: 'Submit Feedback',
                isLoading: _isSubmitting,
                onPressed: _canSubmit ? _handleSubmit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YesNoOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _YesNoOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isSelected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}