import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/complaint_category.dart';
import '../../../models/complaint_draft.dart';
import '../../../repositories/category_repository.dart';
import '../../../widgets/campfix_text_field.dart';
import '../../../widgets/campfix_button.dart';
import '../../../widgets/campfix_step_progress.dart';

class ReportStep1Screen extends StatefulWidget {
  final ComplaintDraft draft;
  final VoidCallback onNext;

  const ReportStep1Screen({
    super.key,
    required this.draft,
    required this.onNext,
  });

  @override
  State<ReportStep1Screen> createState() => _ReportStep1ScreenState();
}

class _ReportStep1ScreenState extends State<ReportStep1Screen> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _selectedCategoryId;
  late Future<List<ComplaintCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _descriptionController = TextEditingController(text: widget.draft.description);
    _selectedCategoryId = widget.draft.categoryId;
    _titleController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
    _categoriesFuture = _categoryRepository.getCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _selectedCategoryId != null &&
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  void _handleNext(List<ComplaintCategory> categories) {
    final category = categories.firstWhere((c) => c.id == _selectedCategoryId);
    widget.draft
      ..categoryId = _selectedCategoryId
      ..categoryName = category.name
      ..title = _titleController.text.trim()
      ..description = _descriptionController.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Report a Problem')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CampFixStepProgress(currentStep: 0, totalSteps: 4),
              const SizedBox(height: AppSpacing.xl),
              Text('What is the problem?', style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('Choose a category and tell us what happened.', style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: FutureBuilder<List<ComplaintCategory>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final categories = snapshot.data!;
                    return ListView(
                      children: [
                        Text('Category', style: textTheme.labelLarge),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: categories.map((category) {
                            final isSelected = category.id == _selectedCategoryId;
                            return ChoiceChip(
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedCategoryId = category.id),
                              avatar: Icon(
                                category.icon,
                                size: 18,
                                color: isSelected ? Colors.white : AppColors.primary,
                              ),
                              label: Text(category.name),
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: AppColors.surfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        CampFixTextField(
                          label: 'Title',
                          hint: 'e.g. Fan not working',
                          controller: _titleController,
                          validator: (_) => null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CampFixTextField(
                          label: 'What happened?',
                          hint: 'Tell us what needs to be fixed...\ne.g. "Fan is not working in Room 204."',
                          controller: _descriptionController,
                          maxLines: 5,
                          validator: (_) => null,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FutureBuilder<List<ComplaintCategory>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? [];
                  return CampFixButton(
                    label: 'Next',
                    onPressed: _canContinue ? () => _handleNext(categories) : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
   }
}

