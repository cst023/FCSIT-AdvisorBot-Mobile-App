import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ResultRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool highlight;

  const ResultRow({
    super.key,
    required this.label,
    this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value ?? '—',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w800,
              color: hasValue && highlight
                  ? AppColors.primary
                  : hasValue
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
