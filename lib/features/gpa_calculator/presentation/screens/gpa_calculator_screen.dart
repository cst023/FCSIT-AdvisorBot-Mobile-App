import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/gpa_provider.dart';
import '../widgets/course_table.dart';
import '../widgets/result_row.dart';
import '../../../../../core/constants/app_colors.dart';

class GpaCalculatorScreen extends StatelessWidget {
  const GpaCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GpaProvider(),
      child: const _GpaCalculatorView(),
    );
  }
}

class _GpaCalculatorView extends StatelessWidget {
  const _GpaCalculatorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Calculate GPA/CGPA'),
        actions: [
          // Reset button — clears all inputs and results
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Reset all',
            onPressed: () {
              context.read<GpaProvider>().resetAll();
              // Also clear the CGPA text controllers via a key rebuild —
              // handled by the _CgpaSection using a ValueKey on the form.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calculator reset'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  width: 180,
                ),
              );
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GpaSection(),
            SizedBox(height: 32),
            _Divider(),
            SizedBox(height: 28),
            _CgpaSection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ==============================
// GPA SECTION
// ==============================

class _GpaSection extends StatelessWidget {
  const _GpaSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GpaProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Heading ----
        const Text(
          'GPA calculation',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter the credit hours and grade for each course\ntaken this semester.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // ---- Course Table ----
        const CourseTable(),
        const SizedBox(height: 16),

        // ---- Validation Error ----
        if (provider.gpaError != null) ...[
          _ErrorBanner(message: provider.gpaError!),
          const SizedBox(height: 10),
        ],

        // ---- Calculate GPA Button ----
        _PrimaryButton(
          label: 'Calculate GPA',
          onPressed: () {
            FocusScope.of(context).unfocus();
            context.read<GpaProvider>().calculateGpa();
          },
        ),
        const SizedBox(height: 16),

        // ---- Results Row ----
        Row(
          children: [
            Expanded(
              child: ResultRow(
                label: 'GPA:',
                value: provider.gpa?.toStringAsFixed(2),
                highlight: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ResultRow(
                label: 'Semester credits:',
                value: provider.semesterCredits?.toString(),
                highlight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==============================
// CGPA SECTION
// ==============================

class _CgpaSection extends StatefulWidget {
  const _CgpaSection();

  @override
  State<_CgpaSection> createState() => _CgpaSectionState();
}

class _CgpaSectionState extends State<_CgpaSection> {
  final _cgpaController = TextEditingController();
  final _creditsController = TextEditingController();

  @override
  void dispose() {
    _cgpaController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GpaProvider>();
    final gpaReady = provider.gpa != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Heading ----
        const Text(
          'CGPA calculation',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),

        // ---- Subtitle — changes based on whether GPA is ready ----
        Text(
          gpaReady
              ? 'GPA for this semester: ${provider.gpa!.toStringAsFixed(2)}  '
                    '(${provider.semesterCredits} credits)\n'
                    'Now enter your previous CGPA and total credits.'
              : 'Calculate your GPA above first, then enter your\n'
                    'current CGPA and total credits taken prior to this semester.',
          style: TextStyle(
            fontSize: 13,
            color: gpaReady ? AppColors.primary : AppColors.textSecondary,
            height: 1.5,
            fontWeight: gpaReady ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 16),

        // ---- Current CGPA Field ----
        const Text(
          'Current CGPA:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        _CgpaTextField(
          controller: _cgpaController,
          hint: 'e.g.: 3.5',
          enabled: gpaReady,
          onChanged: (v) => context.read<GpaProvider>().currentCgpaInput = v,
        ),
        const SizedBox(height: 14),

        // ---- Total Credits Field ----
        const Text(
          'Total Credits Taken:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        _CgpaTextField(
          controller: _creditsController,
          hint: 'e.g.: 45',
          enabled: gpaReady,
          onChanged: (v) =>
              context.read<GpaProvider>().previousCreditsInput = v,
        ),
        const SizedBox(height: 16),

        // ---- Validation Error ----
        if (provider.cgpaError != null) ...[
          _ErrorBanner(message: provider.cgpaError!),
          const SizedBox(height: 10),
        ],

        // ---- Calculate CGPA Button ----
        _PrimaryButton(
          label: 'Calculate CGPA',
          enabled: gpaReady,
          onPressed: () {
            FocusScope.of(context).unfocus();
            context.read<GpaProvider>().calculateCgpa();
          },
        ),
        const SizedBox(height: 16),

        // ---- Results Row ----
        Row(
          children: [
            Expanded(
              child: ResultRow(
                label: 'CGPA:',
                value: provider.cgpa?.toStringAsFixed(2),
                highlight: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ResultRow(
                label: 'Total credits:',
                value: provider.totalCredits?.toString(),
                highlight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==============================
// SHARED SMALL WIDGETS
// ==============================

class _CgpaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _CgpaTextField({
    required this.controller,
    required this.hint,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      style: TextStyle(
        fontSize: 15,
        color: enabled ? AppColors.textPrimary : AppColors.textHint,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: AppColors.divider, thickness: 1);
  }
}
