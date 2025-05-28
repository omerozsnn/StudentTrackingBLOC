import 'package:equatable/equatable.dart';
import '../../models/homework_tracking_model.dart';

enum HomeworkTrackingStatus { initial, loading, loaded, error }

class HomeworkTrackingState extends Equatable {
  final HomeworkTrackingStatus status;
  final List<HomeworkTracking> trackingRecords;
  final HomeworkTracking? selectedTracking;
  final String? errorMessage;

  const HomeworkTrackingState({
    this.status = HomeworkTrackingStatus.initial,
    this.trackingRecords = const [],
    this.selectedTracking,
    this.errorMessage,
  });

  HomeworkTrackingState copyWith({
    HomeworkTrackingStatus? status,
    List<HomeworkTracking>? trackingRecords,
    HomeworkTracking? selectedTracking,
    String? errorMessage,
    bool clearSelectedTracking = false,
    bool clearErrorMessage = false,
  }) {
    return HomeworkTrackingState(
      status: status ?? this.status,
      trackingRecords: trackingRecords ?? this.trackingRecords,
      selectedTracking: clearSelectedTracking
          ? null
          : (selectedTracking ?? this.selectedTracking),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, trackingRecords, selectedTracking, errorMessage];
}
