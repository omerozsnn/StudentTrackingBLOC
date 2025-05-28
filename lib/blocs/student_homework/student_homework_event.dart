import 'package:equatable/equatable.dart';
import '../../models/student_homework_model.dart';

abstract class StudentHomeworkEvent extends Equatable {
  const StudentHomeworkEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllStudentHomeworks extends StudentHomeworkEvent {
  const LoadAllStudentHomeworks();
}

class LoadStudentHomeworksByStudentId extends StudentHomeworkEvent {
  final int studentId;

  const LoadStudentHomeworksByStudentId(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadStudentHomeworkById extends StudentHomeworkEvent {
  final int id;

  const LoadStudentHomeworkById(this.id);

  @override
  List<Object?> get props => [id];
}

class AddStudentHomework extends StudentHomeworkEvent {
  final StudentHomework studentHomework;

  const AddStudentHomework(this.studentHomework);

  @override
  List<Object?> get props => [studentHomework];
}

class AddBulkStudentHomeworks extends StudentHomeworkEvent {
  final List<StudentHomework> studentHomeworks;

  const AddBulkStudentHomeworks(this.studentHomeworks);

  @override
  List<Object?> get props => [studentHomeworks];
}

class UpdateStudentHomework extends StudentHomeworkEvent {
  final StudentHomework studentHomework;

  const UpdateStudentHomework(this.studentHomework);

  @override
  List<Object?> get props => [studentHomework];
}

class DeleteStudentHomework extends StudentHomeworkEvent {
  final int id;

  const DeleteStudentHomework(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadStudentsByClassAndHomework extends StudentHomeworkEvent {
  final int classId;
  final int homeworkId;

  const LoadStudentsByClassAndHomework(this.classId, this.homeworkId);

  @override
  List<Object?> get props => [classId, homeworkId];
}

class BulkUpdateStudentHomeworks extends StudentHomeworkEvent {
  final List<Map<String, dynamic>> updates;

  const BulkUpdateStudentHomeworks(this.updates);

  @override
  List<Object?> get props => [updates];
}

class BulkGetStudentHomeworks extends StudentHomeworkEvent {
  final List<int> studentIds;

  const BulkGetStudentHomeworks(this.studentIds);

  @override
  List<Object?> get props => [studentIds];
}

class ClearStudentHomeworkSelection extends StudentHomeworkEvent {
  const ClearStudentHomeworkSelection();
}
