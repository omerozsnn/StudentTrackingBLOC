import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';

abstract class TeacherCommentState extends Equatable {
  const TeacherCommentState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TeacherCommentInitial extends TeacherCommentState {}

// Loading state
class TeacherCommentLoading extends TeacherCommentState {}

// Classes loaded state
class ClassesLoadedState extends TeacherCommentState {
  final List<String> classes;
  final String? selectedClass;

  const ClassesLoadedState({
    required this.classes,
    this.selectedClass,
  });

  @override
  List<Object?> get props => [classes, selectedClass];

  ClassesLoadedState copyWith({
    List<String>? classes,
    String? selectedClass,
    bool clearSelectedClass = false,
  }) {
    return ClassesLoadedState(
      classes: classes ?? this.classes,
      selectedClass:
          clearSelectedClass ? null : selectedClass ?? this.selectedClass,
    );
  }
}

// Students loading state - keeps loaded classes while loading students
class StudentsLoadingState extends TeacherCommentState {
  final List<String> classes;
  final String? selectedClass;

  const StudentsLoadingState({
    required this.classes,
    this.selectedClass,
  });

  @override
  List<Object?> get props => [classes, selectedClass];
}

// Students loaded state
class StudentsLoadedState extends TeacherCommentState {
  final List<Student> students;
  final String selectedClass;
  final Student? selectedStudent;
  final Set<Student> selectedStudents;
  final bool isMultiSelectMode;

  const StudentsLoadedState({
    required this.students,
    required this.selectedClass,
    this.selectedStudent,
    this.selectedStudents = const {},
    this.isMultiSelectMode = false,
  });

  @override
  List<Object?> get props => [
        students,
        selectedClass,
        selectedStudent,
        selectedStudents,
        isMultiSelectMode
      ];

  StudentsLoadedState copyWith({
    List<Student>? students,
    String? selectedClass,
    Student? selectedStudent,
    Set<Student>? selectedStudents,
    bool? isMultiSelectMode,
    bool clearSelectedStudent = false,
  }) {
    return StudentsLoadedState(
      students: students ?? this.students,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedStudent:
          clearSelectedStudent ? null : selectedStudent ?? this.selectedStudent,
      selectedStudents: selectedStudents ?? this.selectedStudents,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
    );
  }
}

// Feedback options loaded state
class FeedbackOptionsLoadedState extends TeacherCommentState {
  final List<TeacherFeedbackOption> options;
  final Set<int> selectedOptionIds;

  const FeedbackOptionsLoadedState({
    required this.options,
    this.selectedOptionIds = const {},
  });

  @override
  List<Object?> get props => [options, selectedOptionIds];

  FeedbackOptionsLoadedState copyWith({
    List<TeacherFeedbackOption>? options,
    Set<int>? selectedOptionIds,
    bool clearSelection = false,
  }) {
    return FeedbackOptionsLoadedState(
      options: options ?? this.options,
      selectedOptionIds:
          clearSelection ? {} : selectedOptionIds ?? this.selectedOptionIds,
    );
  }
}

// Student feedback loaded state
class StudentFeedbackLoadedState extends TeacherCommentState {
  final int studentId;
  final List<Map<String, dynamic>> feedbackList;

  const StudentFeedbackLoadedState({
    required this.studentId,
    required this.feedbackList,
  });

  @override
  List<Object?> get props => [studentId, feedbackList];
}

// Operation success state
class TeacherCommentOperationSuccess extends TeacherCommentState {
  final String message;

  const TeacherCommentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Error state
class TeacherCommentError extends TeacherCommentState {
  final String message;

  const TeacherCommentError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bulk feedback operation state
class BulkFeedbackOperationState extends TeacherCommentState {
  final bool isInProgress;
  final int successCount;
  final int failureCount;
  final int totalCount;

  const BulkFeedbackOperationState({
    required this.isInProgress,
    this.successCount = 0,
    this.failureCount = 0,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props =>
      [isInProgress, successCount, failureCount, totalCount];

  BulkFeedbackOperationState copyWith({
    bool? isInProgress,
    int? successCount,
    int? failureCount,
    int? totalCount,
  }) {
    return BulkFeedbackOperationState(
      isInProgress: isInProgress ?? this.isInProgress,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
