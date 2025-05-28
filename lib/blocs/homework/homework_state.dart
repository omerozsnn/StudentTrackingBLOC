import 'package:equatable/equatable.dart';
import '../../models/homework_model.dart';

enum HomeworkStatus { initial, loading, loaded, error }

class HomeworkState extends Equatable {
  final HomeworkStatus status;
  final List<Homework> homeworks;
  final Homework? selectedHomework;
  final String? errorMessage;

  const HomeworkState({
    this.status = HomeworkStatus.initial,
    this.homeworks = const [],
    this.selectedHomework,
    this.errorMessage,
  });

  HomeworkState copyWith({
    HomeworkStatus? status,
    List<Homework>? homeworks,
    Homework? selectedHomework,
    String? errorMessage,
    bool clearSelectedHomework = false,
    bool clearErrorMessage = false,
  }) {
    return HomeworkState(
      status: status ?? this.status,
      homeworks: homeworks ?? this.homeworks,
      selectedHomework: clearSelectedHomework
          ? null
          : (selectedHomework ?? this.selectedHomework),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, homeworks, selectedHomework, errorMessage];
}
