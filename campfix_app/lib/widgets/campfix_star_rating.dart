  import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CampFixStarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  const CampFixStarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = starValue <= rating;
        return GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: filled ? AppColors.warning : AppColors.textTertiary,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}