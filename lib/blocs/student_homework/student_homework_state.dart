import 'package:equatable/equatable.dart';
import '../../models/student_homework_model.dart';

enum StudentHomeworkStatus { initial, loading, loaded, error }

class StudentHomeworkState extends Equatable {
  final StudentHomeworkStatus status;
  final List<StudentHomework> studentHomeworks;
  final List<dynamic> studentsForHomework;
  final StudentHomework? selectedStudentHomework;
  final String? errorMessage;

  const StudentHomeworkState({
    this.status = StudentHomeworkStatus.initial,
    this.studentHomeworks = const [],
    this.studentsForHomework = const [],
    this.selectedStudentHomework,
    this.errorMessage,
  });

  StudentHomeworkState copyWith({
    StudentHomeworkStatus? status,
    List<StudentHomework>? studentHomeworks,
    List<dynamic>? studentsForHomework,
    StudentHomework? selectedStudentHomework,
    String? errorMessage,
    bool clearSelectedStudentHomework = false,
    bool clearErrorMessage = false,
    bool clearStudentsForHomework = false,
  }) {
    return StudentHomeworkState(
      status: status ?? this.status,
      studentHomeworks: studentHomeworks ?? this.studentHomeworks,
      studentsForHomework: clearStudentsForHomework
          ? []
          : (studentsForHomework ?? this.studentsForHomework),
      selectedStudentHomework: clearSelectedStudentHomework
          ? null
          : (selectedStudentHomework ?? this.selectedStudentHomework),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        studentHomeworks,
        studentsForHomework,
        selectedStudentHomework,
        errorMessage
      ];
}
