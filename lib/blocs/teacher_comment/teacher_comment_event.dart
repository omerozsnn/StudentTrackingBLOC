import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

abstract class TeacherCommentEvent extends Equatable {
  const TeacherCommentEvent();

  @override
  List<Object?> get props => [];
}

// Event to load classes for dropdown selection
class LoadClassesEvent extends TeacherCommentEvent {}

// Event to load students from a specific class
class LoadStudentsByClassEvent extends TeacherCommentEvent {
  final String className;

  const LoadStudentsByClassEvent(this.className);

  @override
  List<Object?> get props => [className];
}

// Event to select a student for viewing/adding feedback
class SelectStudentEvent extends TeacherCommentEvent {
  final Student student;

  const SelectStudentEvent(this.student);

  @override
  List<Object?> get props => [student];
}

// Event to clear the currently selected student
class ClearSelectedStudentEvent extends TeacherCommentEvent {}

// Event to load feedback options for dropdown
class LoadFeedbackOptionsEvent extends TeacherCommentEvent {}

// Event to load feedback for a specific student
class LoadStudentFeedbackEvent extends TeacherCommentEvent {
  final int studentId;

  const LoadStudentFeedbackEvent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

// Event to add feedback to a student
class AddFeedbackEvent extends TeacherCommentEvent {
  final int studentId;
  final Set<int> feedbackOptionIds;

  const AddFeedbackEvent({
    required this.studentId,
    required this.feedbackOptionIds,
  });

  @override
  List<Object?> get props => [studentId, feedbackOptionIds];
}

// Event to delete a feedback entry
class DeleteFeedbackEvent extends TeacherCommentEvent {
  final int feedbackId;

  const DeleteFeedbackEvent(this.feedbackId);

  @override
  List<Object?> get props => [feedbackId];
}

// Event to select/deselect students for bulk operations
class UpdateSelectedStudentsEvent extends TeacherCommentEvent {
  final Set<Student> selectedStudents;

  const UpdateSelectedStudentsEvent(this.selectedStudents);

  @override
  List<Object?> get props => [selectedStudents];
}

// Event to select/deselect feedback options
class UpdateSelectedFeedbackOptionsEvent extends TeacherCommentEvent {
  final Set<int> selectedOptionIds;

  const UpdateSelectedFeedbackOptionsEvent(this.selectedOptionIds);

  @override
  List<Object?> get props => [selectedOptionIds];
}

// Event to add bulk feedback
class AddBulkFeedbackEvent extends TeacherCommentEvent {
  final Set<Student> students;
  final Set<int> feedbackOptionIds;

  const AddBulkFeedbackEvent({
    required this.students,
    required this.feedbackOptionIds,
  });

  @override
  List<Object?> get props => [students, feedbackOptionIds];
}

// Event to toggle multi-select mode
class ToggleMultiSelectModeEvent extends TeacherCommentEvent {
  final bool isMultiSelectMode;

  const ToggleMultiSelectModeEvent(this.isMultiSelectMode);

  @override
  List<Object?> get props => [isMultiSelectMode];
}
