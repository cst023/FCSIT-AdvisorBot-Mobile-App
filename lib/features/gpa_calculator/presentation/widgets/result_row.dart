// Displays a labelled result value (e.g. "GPA: 3.45").
// Used for both GPA and CGPA result rows.

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ResultRow extends StatelessWidget {
  final String label;
  final String? value;       // null = not yet calculated (shows "—")
  final bool highlight;      // true = show value in primary blue

  const ResultRow({
    super.key,
    required this.label,
    this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value ?? '—',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: value != null && highlight
                ? AppColors.primary
                : value != null
                    ? AppColors.textPrimary
                    : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}