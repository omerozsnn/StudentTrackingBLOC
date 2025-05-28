import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';

abstract class TeacherFeedbackState extends Equatable {
  const TeacherFeedbackState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TeacherFeedbackInitial extends TeacherFeedbackState {}

// Loading state
class TeacherFeedbackLoading extends TeacherFeedbackState {}

// State when teacher feedback options are loaded
class TeacherFeedbackOptionsLoaded extends TeacherFeedbackState {
  final List<TeacherFeedbackOption> options;
  final TeacherFeedbackOption? selectedOption;

  const TeacherFeedbackOptionsLoaded(this.options, {this.selectedOption});

  @override
  List<Object?> get props => [options, selectedOption];

  TeacherFeedbackOptionsLoaded copyWith({
    List<TeacherFeedbackOption>? options,
    TeacherFeedbackOption? selectedOption,
    bool clearSelection = false,
  }) {
    return TeacherFeedbackOptionsLoaded(
      options ?? this.options,
      selectedOption:
          clearSelection ? null : selectedOption ?? this.selectedOption,
    );
  }
}

// State for successful operation
class TeacherFeedbackOperationSuccess extends TeacherFeedbackState {
  final String message;

  const TeacherFeedbackOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// State for operation error
class TeacherFeedbackError extends TeacherFeedbackState {
  final String message;

  const TeacherFeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}
