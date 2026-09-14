import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/campfix_button.dart';
import '../../widgets/campfix_outlined_button.dart';
import '../../widgets/campfix_text_field.dart';
import '../../widgets/campfix_card.dart';
import '../../widgets/campfix_status_chip.dart';
import '../../widgets/campfix_priority_badge.dart';

class ComponentShowcaseScreen extends StatelessWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.appName, style: textTheme.displayMedium),
            const SizedBox(height: 4),
            Text(AppConstants.appTagline, style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xxl),

            Text('Buttons', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            CampFixButton(label: 'Report a Problem', onPressed: () {}),
            const SizedBox(height: AppSpacing.sm),
            CampFixOutlinedButton(label: 'Cancel', onPressed: () {}),
            const SizedBox(height: AppSpacing.sm),
            const CampFixButton(label: 'Loading...', onPressed: null, isLoading: true),
            const SizedBox(height: AppSpacing.xxl),

            Text('Text Field', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const CampFixTextField(
              label: 'What happened?',
              hint: 'e.g. Fan is not working in Room 204',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text('Status Chips', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                CampFixStatusChip(status: 'SUBMITTED'),
                CampFixStatusChip(status: 'ASSIGNED'),
                CampFixStatusChip(status: 'IN_PROGRESS'),
                CampFixStatusChip(status: 'RESOLVED'),
                CampFixStatusChip(status: 'CANCELLED'),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text('Priority Badges', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                CampFixPriorityBadge(priority: 'LOW'),
                CampFixPriorityBadge(priority: 'MEDIUM'),
                CampFixPriorityBadge(priority: 'HIGH'),
                CampFixPriorityBadge(priority: 'CRITICAL'),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text('Complaint Card Example', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            CampFixCard(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CF-2026-00025', style: textTheme.labelLarge),
                      const CampFixPriorityBadge(priority: 'HIGH'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Classroom Fan Not Working', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text('📍 Main Block • Room 204', style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CampFixStatusChip(status: 'IN_PROGRESS'),
                      Text('Updated 12 min ago', style: textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}