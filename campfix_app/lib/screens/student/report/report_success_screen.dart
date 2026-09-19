import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/campfix_button.dart';

class ReportSuccessScreen extends StatelessWidget {
  final String complaintNumber;

  const ReportSuccessScreen({super.key, required this.complaintNumber});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Complaint Submitted!', style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your complaint has been received and is being processed.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  complaintNumber,
                  style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              CampFixButton(
                label: 'Done',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}