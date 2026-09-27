import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';

class CampFixSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final int activeFilterCount;

  const CampFixSearchBar({
    super.key,
    this.hint = 'Search complaints...',
    required this.onChanged,
    this.onFilterTap,
    this.activeFilterCount = 0,
  });

  @override
  State<CampFixSearchBar> createState() => _CampFixSearchBarState();
}

class _CampFixSearchBarState extends State<CampFixSearchBar> {
  Timer? _debounce;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onChanged(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (widget.onFilterTap != null) ...[
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: widget.onFilterTap,
                ),
              ),
              if (widget.activeFilterCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Text(
                      '${widget.activeFilterCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}