import 'package:equatable/equatable.dart';
import '../../models/homework_tracking_model.dart';

abstract class HomeworkTrackingEvent extends Equatable {
  const HomeworkTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllHomeworkTracking extends HomeworkTrackingEvent {
  const LoadAllHomeworkTracking();
}

class LoadHomeworkTrackingById extends HomeworkTrackingEvent {
  final int id;

  const LoadHomeworkTrackingById(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadHomeworkTrackingByStudentHomeworkId extends HomeworkTrackingEvent {
  final int studentHomeworkId;

  const LoadHomeworkTrackingByStudentHomeworkId(this.studentHomeworkId);

  @override
  List<Object?> get props => [studentHomeworkId];
}

class AddHomeworkTracking extends HomeworkTrackingEvent {
  final HomeworkTracking tracking;

  const AddHomeworkTracking(this.tracking);

  @override
  List<Object?> get props => [tracking];
}

class UpdateHomeworkTracking extends HomeworkTrackingEvent {
  final HomeworkTracking tracking;

  const UpdateHomeworkTracking(this.tracking);

  @override
  List<Object?> get props => [tracking];
}

class DeleteHomeworkTracking extends HomeworkTrackingEvent {
  final int id;

  const DeleteHomeworkTracking(this.id);

  @override
  List<Object?> get props => [id];
}

class BulkUpsertHomeworkTracking extends HomeworkTrackingEvent {
  final List<HomeworkTracking> trackingList;

  const BulkUpsertHomeworkTracking(this.trackingList);

  @override
  List<Object?> get props => [trackingList];
}

class BulkGetHomeworkTracking extends HomeworkTrackingEvent {
  final List<int> studentHomeworkIds;

  const BulkGetHomeworkTracking(this.studentHomeworkIds);

  @override
  List<Object?> get props => [studentHomeworkIds];
}

class BulkGetHomeworkTrackingForHomework extends HomeworkTrackingEvent {
  final List<int> studentIds;
  final int homeworkId;

  const BulkGetHomeworkTrackingForHomework(this.studentIds, this.homeworkId);

  @override
  List<Object?> get props => [studentIds, homeworkId];
}

class ClearHomeworkTrackingSelection extends HomeworkTrackingEvent {
  const ClearHomeworkTrackingSelection();
}
