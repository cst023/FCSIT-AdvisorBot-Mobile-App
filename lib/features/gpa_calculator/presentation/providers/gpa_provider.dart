import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/course_entry.dart';

class GpaProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  // ---- Course Table State ----

  late List<CourseEntry> _courses;

  // Start with 4 empty rows as per the design.
  static const _defaultRowCount = 4;

  // ---- GPA Result State ----

  double? _gpa;
  int? _semesterCredits;

  // ---- CGPA Input State ----

  String currentCgpaInput = '';
  String previousCreditsInput = '';

  // ---- CGPA Result State ----

  double? _cgpa;
  int? _totalCredits;

  // ---- Validation Error State ----
  // Null means no error. Non-null string is shown to the user.

  String? _gpaError;
  String? _cgpaError;

  // ---- Public Getters ----

  List<CourseEntry> get courses => List.unmodifiable(_courses);
  double? get gpa => _gpa;
  int? get semesterCredits => _semesterCredits;
  double? get cgpa => _cgpa;
  int? get totalCredits => _totalCredits;
  String? get gpaError => _gpaError;
  String? get cgpaError => _cgpaError;

  // ---- Initialisation ----

  GpaProvider() {
    _courses = List.generate(
      _defaultRowCount,
      (_) => CourseEntry(id: _uuid.v4()),
    );
  }

  // ---- Course Table Actions ----

  void updateCredits(String id, String value) {
    _courses = _courses.map((c) {
      return c.id == id ? c.copyWith(credits: value) : c;
    }).toList();
    // Clear previous results when inputs change so stale
    // values are not shown alongside new inputs.
    _clearGpaResult();
    notifyListeners();
  }

  void updateGrade(String id, String? grade) {
    _courses = _courses.map((c) {
      return c.id == id ? c.copyWith(grade: grade) : c;
    }).toList();
    _clearGpaResult();
    notifyListeners();
  }

  void addCourse() {
    _courses = [..._courses, CourseEntry(id: _uuid.v4())];
    notifyListeners();
  }

  // Minimum 1 row — enforced here so the UI remove button can
  // simply call this without its own guard logic.
  void removeCourse(String id) {
    if (_courses.length <= 1) return;
    _courses = _courses.where((c) => c.id != id).toList();
    _clearGpaResult();
    notifyListeners();
  }

  // ---- GPA Calculation ----

  void calculateGpa() {
    _gpaError = null;

    // Validate: every row must have both credits and a grade.
    for (int i = 0; i < _courses.length; i++) {
      final c = _courses[i];
      final row = i + 1;

      if (c.credits.trim().isEmpty) {
        _gpaError = 'Row $row: Please enter the credit hours.';
        notifyListeners();
        return;
      }

      final credit = double.tryParse(c.credits.trim());
      if (credit == null || credit <= 0) {
        _gpaError = 'Row $row: Credits must be a positive number.';
        notifyListeners();
        return;
      }

      if (c.grade == null) {
        _gpaError = 'Row $row: Please select a grade.';
        notifyListeners();
        return;
      }
    }

    // All rows valid — calculate.
    double totalGradePoints = 0;
    double totalCredits = 0;

    for (final c in _courses) {
      final credit = double.parse(c.credits.trim());
      totalGradePoints += (c.gradePoint! * credit);
      totalCredits += credit;
    }

    _gpa = double.parse((totalGradePoints / totalCredits).toStringAsFixed(2));
    _semesterCredits = totalCredits.toInt();

    // Clear any stale CGPA result since the GPA it was based on may have changed.
    _clearCgpaResult();

    notifyListeners();
  }

  // ---- CGPA Calculation ----

  void calculateCgpa() {
    _cgpaError = null;

    // GPA must be calculated first.
    if (_gpa == null) {
      _cgpaError = 'Please calculate your GPA first.';
      notifyListeners();
      return;
    }

    // Validate current CGPA input.
    if (currentCgpaInput.trim().isEmpty) {
      _cgpaError = 'Please enter your current CGPA.';
      notifyListeners();
      return;
    }
    final prevCgpa = double.tryParse(currentCgpaInput.trim());
    if (prevCgpa == null || prevCgpa < 0 || prevCgpa > 4) {
      _cgpaError = 'Current CGPA must be a number between 0.00 and 4.00.';
      notifyListeners();
      return;
    }

    // Validate total previous credits input.
    if (previousCreditsInput.trim().isEmpty) {
      _cgpaError = 'Please enter your total credits taken.';
      notifyListeners();
      return;
    }
    final prevCredits = double.tryParse(previousCreditsInput.trim());
    if (prevCredits == null || prevCredits < 0) {
      _cgpaError = 'Total credits must be a non-negative number.';
      notifyListeners();
      return;
    }

    // Calculate new CGPA:
    // (prev_cgpa × prev_credits + gpa × semester_credits)
    // ÷ (prev_credits + semester_credits)
    final semCredits = _semesterCredits!.toDouble();
    final newTotalCredits = prevCredits + semCredits;
    final newTotalPoints = (prevCgpa * prevCredits) + (_gpa! * semCredits);

    _cgpa = double.parse(
        (newTotalPoints / newTotalCredits).toStringAsFixed(2));
    _totalCredits = newTotalCredits.toInt();

    notifyListeners();
  }

  // ---- Reset ----

  void resetAll() {
    _courses = List.generate(
      _defaultRowCount,
      (_) => CourseEntry(id: _uuid.v4()),
    );
    currentCgpaInput = '';
    previousCreditsInput = '';
    _clearGpaResult();
    _clearCgpaResult();
    _gpaError = null;
    _cgpaError = null;
    notifyListeners();
  }

  // ---- Private Helpers ----

  void _clearGpaResult() {
    _gpa = null;
    _semesterCredits = null;
    _clearCgpaResult();
  }

  void _clearCgpaResult() {
    _cgpa = null;
    _totalCredits = null;
  }
}