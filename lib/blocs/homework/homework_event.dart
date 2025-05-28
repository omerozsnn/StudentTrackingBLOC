import 'package:equatable/equatable.dart';
import '../../models/homework_model.dart';

abstract class HomeworkEvent extends Equatable {
  const HomeworkEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeworks extends HomeworkEvent {
  const LoadHomeworks();
}

class AddHomework extends HomeworkEvent {
  final Homework homework;

  const AddHomework(this.homework);

  @override
  List<Object?> get props => [homework];
}

class UpdateHomework extends HomeworkEvent {
  final Homework homework;

  const UpdateHomework(this.homework);

  @override
  List<Object?> get props => [homework];
}

class DeleteHomework extends HomeworkEvent {
  final int id;

  const DeleteHomework(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectHomework extends HomeworkEvent {
  final Homework? homework;

  const SelectHomework(this.homework);

  @override
  List<Object?> get props => [homework];
}

class ClearSelection extends HomeworkEvent {
  const ClearSelection();
}
