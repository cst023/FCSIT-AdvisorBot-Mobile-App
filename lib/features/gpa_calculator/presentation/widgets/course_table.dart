import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/course_entry.dart';
import '../providers/gpa_provider.dart';
import '../../../../../core/constants/app_colors.dart';

class CourseTable extends StatelessWidget {
  const CourseTable({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<GpaProvider>().courses;

    return Column(
      children: [
        // ---- Header Row ----
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              const SizedBox(width: 36), // spacer for delete button column
              Expanded(
                flex: 4,
                child: Text(
                  'Course credits',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  'Grade',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ---- Course Rows ----
        ...courses.map(
          (course) => _CourseRow(
            key: ValueKey(course.id),
            course: course,
          ),
        ),

        // ---- Add Course Button ----
        const SizedBox(height: 8),
        _AddCourseButton(),
      ],
    );
  }
}

// ==============================
// SINGLE COURSE ROW
// ==============================

class _CourseRow extends StatefulWidget {
  final CourseEntry course;
  const _CourseRow({super.key, required this.course});

  @override
  State<_CourseRow> createState() => _CourseRowState();
}

class _CourseRowState extends State<_CourseRow> {
  late final TextEditingController _creditsController;

  @override
  void initState() {
    super.initState();
    _creditsController =
        TextEditingController(text: widget.course.credits);
  }

  @override
  void dispose() {
    _creditsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GpaProvider>();
    final canRemove = context.watch<GpaProvider>().courses.length > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ---- Delete Button ----
          SizedBox(
            width: 36,
            child: canRemove
                ? IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        size: 20, color: AppColors.error),
                    tooltip: 'Remove row',
                    onPressed: () => provider.removeCourse(widget.course.id),
                  )
                : const SizedBox.shrink(),
          ),

          // ---- Credits Field ----
          Expanded(
            flex: 4,
            child: _TableCell(
              child: TextField(
                controller: _creditsController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d*')),
                ],
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Credits',
                  hintStyle:
                      TextStyle(fontSize: 13, color: AppColors.textHint),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                onChanged: (v) =>
                    provider.updateCredits(widget.course.id, v),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // ---- Grade Dropdown ----
          Expanded(
            flex: 5,
            child: _TableCell(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.course.grade,
                  isExpanded: true,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Grade',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textHint)),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                  items: CourseEntry.gradeOptions
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '$g  (${CourseEntry.gradePoints[g]!.toStringAsFixed(2)})',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      provider.updateGrade(widget.course.id, v),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================
// TABLE CELL CONTAINER
// ==============================

class _TableCell extends StatelessWidget {
  final Widget child;
  const _TableCell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.surface,
      ),
      child: child,
    );
  }
}

// ==============================
// ADD COURSE BUTTON
// ==============================

class _AddCourseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.read<GpaProvider>().addCourse,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(6),
          color: AppColors.primaryLight.withOpacity(0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              'Add course',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
