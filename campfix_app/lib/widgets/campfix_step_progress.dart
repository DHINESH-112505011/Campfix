import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CampFixStepProgress extends StatelessWidget {
  final int currentStep; // 0-indexed
  final int totalSteps;

  const CampFixStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
} 