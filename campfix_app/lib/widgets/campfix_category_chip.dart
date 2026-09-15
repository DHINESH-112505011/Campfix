import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/complaint_category.dart';

class CampFixCategoryChip extends StatelessWidget {
  final ComplaintCategory category;
  final VoidCallback? onTap;

  const CampFixCategoryChip({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(category.icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}