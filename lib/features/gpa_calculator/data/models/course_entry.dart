// Represents a single row in the GPA course table.
class CourseEntry {
  final String id;
  final String credits; 
  final String? grade;  

  const CourseEntry({
    required this.id,
    this.credits = '',
    this.grade,
  });

  CourseEntry copyWith({
    String? credits,
    String? grade,
    bool clearGrade = false,
  }) {
    return CourseEntry(
      id: id,
      credits: credits ?? this.credits,
      grade: clearGrade ? null : (grade ?? this.grade),
    );
  }

  // Grade → grade point lookup table.
  static const Map<String, double> gradePoints = {
    'A':  4.00,
    'A-': 3.67,
    'B+': 3.33,
    'B':  3.00,
    'B-': 2.67,
    'C+': 2.33,
    'C':  2.00,
    'C-': 1.67,
    'D':  1.00,
    'F':  0.00,
  };

  static List<String> get gradeOptions => gradePoints.keys.toList();

  double? get gradePoint => grade != null ? gradePoints[grade] : null;
}