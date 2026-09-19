import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/complaint_draft.dart';
import '../../../widgets/campfix_button.dart';
import '../../../widgets/campfix_outlined_button.dart';
import '../../../widgets/campfix_step_progress.dart';

class ReportStep3Screen extends StatefulWidget {
  final ComplaintDraft draft;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ReportStep3Screen({
    super.key,
    required this.draft,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ReportStep3Screen> createState() => _ReportStep3ScreenState();
}

class _ReportStep3ScreenState extends State<ReportStep3Screen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.draft.imageFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to access camera/gallery. Please check app permissions.')),
      );
    }
  }

  void _handleNext() {
    widget.draft.imageFile = _selectedImage;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              const CampFixStepProgress(currentStep: 2, totalSteps: 4),
              const SizedBox(height: AppSpacing.xl),
              Text('Add a photo', style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('A photo helps our team fix it faster. Optional.', style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: Center(
                  child: _selectedImage == null
                      ? Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, size: 48, color: AppColors.textTertiary),
                              const SizedBox(height: AppSpacing.sm),
                              Text('No photo added yet', style: textTheme.bodyMedium),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 260,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                                    onPressed: () => setState(() => _selectedImage = null),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: CampFixOutlinedButton(
                      label: 'Camera',
                      icon: Icons.camera_alt_outlined,
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CampFixOutlinedButton(
                      label: 'Gallery',
                      icon: Icons.photo_library_outlined,
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              CampFixButton(
                label: _selectedImage == null ? 'Skip' : 'Next',
                onPressed: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}