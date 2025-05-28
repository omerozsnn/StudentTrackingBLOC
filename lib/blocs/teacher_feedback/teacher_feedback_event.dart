import 'package:equatable/equatable.dart';

abstract class TeacherFeedbackEvent extends Equatable {
  const TeacherFeedbackEvent();

  @override
  List<Object?> get props => [];
}

// Event to load teacher feedback options
class LoadTeacherFeedbackOptions extends TeacherFeedbackEvent {}

// Event to add a new teacher feedback option
class AddTeacherFeedbackOption extends TeacherFeedbackEvent {
  final String gorusMetni;

  const AddTeacherFeedbackOption(this.gorusMetni);

  @override
  List<Object?> get props => [gorusMetni];
}

// Event to update an existing teacher feedback option
class UpdateTeacherFeedbackOption extends TeacherFeedbackEvent {
  final int id;
  final String gorusMetni;

  const UpdateTeacherFeedbackOption(this.id, this.gorusMetni);

  @override
  List<Object?> get props => [id, gorusMetni];
}

// Event to delete a teacher feedback option
class DeleteTeacherFeedbackOption extends TeacherFeedbackEvent {
  final int id;

  const DeleteTeacherFeedbackOption(this.id);

  @override
  List<Object?> get props => [id];
}

// Event to select a specific teacher feedback option
class SelectTeacherFeedbackOption extends TeacherFeedbackEvent {
  final int id;

  const SelectTeacherFeedbackOption(this.id);

  @override
  List<Object?> get props => [id];
}

// Event to clear selection
class ClearSelectedTeacherFeedbackOption extends TeacherFeedbackEvent {}

// Event for loading state
class TeacherFeedbackLoading extends TeacherFeedbackEvent {}
