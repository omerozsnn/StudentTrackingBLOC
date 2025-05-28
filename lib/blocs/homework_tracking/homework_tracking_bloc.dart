import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/homework_tracking_model.dart';
import 'homework_tracking_event.dart';
import 'homework_tracking_state.dart';
import 'homework_tracking_repository.dart';

class HomeworkTrackingBloc
    extends Bloc<HomeworkTrackingEvent, HomeworkTrackingState> {
  final HomeworkTrackingRepository _repository;

  HomeworkTrackingBloc({required HomeworkTrackingRepository repository})
      : _repository = repository,
        super(const HomeworkTrackingState()) {
    on<LoadAllHomeworkTracking>(_onLoadAllHomeworkTracking);
    on<LoadHomeworkTrackingById>(_onLoadHomeworkTrackingById);
    on<LoadHomeworkTrackingByStudentHomeworkId>(
        _onLoadHomeworkTrackingByStudentHomeworkId);
    on<AddHomeworkTracking>(_onAddHomeworkTracking);
    on<UpdateHomeworkTracking>(_onUpdateHomeworkTracking);
    on<DeleteHomeworkTracking>(_onDeleteHomeworkTracking);
    on<BulkUpsertHomeworkTracking>(_onBulkUpsertHomeworkTracking);
    on<BulkGetHomeworkTracking>(_onBulkGetHomeworkTracking);
    on<BulkGetHomeworkTrackingForHomework>(
        _onBulkGetHomeworkTrackingForHomework);
    on<ClearHomeworkTrackingSelection>(_onClearHomeworkTrackingSelection);
  }

  Future<void> _onLoadAllHomeworkTracking(LoadAllHomeworkTracking event,
      Emitter<HomeworkTrackingState> emit) async {
    emit(state.copyWith(status: HomeworkTrackingStatus.loading));
    try {
      final trackingRecords = await _repository.getAllHomeworkTracking();
      emit(state.copyWith(
        status: HomeworkTrackingStatus.loaded,
        trackingRecords: trackingRecords,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadHomeworkTrackingById(LoadHomeworkTrackingById event,
      Emitter<HomeworkTrackingState> emit) async {
    emit(state.copyWith(status: HomeworkTrackingStatus.loading));
    try {
      final tracking = await _repository.getHomeworkTrackingById(event.id);
      emit(state.copyWith(
        status: HomeworkTrackingStatus.loaded,
        selectedTracking: tracking,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadHomeworkTrackingByStudentHomeworkId(
      LoadHomeworkTrackingByStudentHomeworkId event,
      Emitter<HomeworkTrackingState> emit) async {
    emit(state.copyWith(status: HomeworkTrackingStatus.loading));
    try {
      final trackingRecords = await _repository
          .getTrackingByStudentHomeworkId(event.studentHomeworkId);
      emit(state.copyWith(
        status: HomeworkTrackingStatus.loaded,
        trackingRecords: trackingRecords,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddHomeworkTracking(
      AddHomeworkTracking event, Emitter<HomeworkTrackingState> emit) async {
    emit(state.copyWith(status: HomeworkTrackingStatus.loading));
    try {
      await _repository.addHomeworkTracking(event.tracking);
      final trackingRecords = await _repository.getAllHomeworkTracking();
      emit(state.copyWith(
        status: HomeworkTrackingStatus.loaded,
        trackingRecords: trackingRecords,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateHomeworkTracking(
      UpdateHomeworkTracking event, Emitter<HomeworkTrackingState> emit) async {
    emit(state.copyWith(status: HomeworkTrackingStatus.loading));
    try {
      await _repository.updateHomeworkTracking(event.tracking);
      final trackingRecords = await _repository.getAllHomeworkTracking();
      emit(state.copyWith(
        status: HomeworkTrackingStatus.loaded,
        trackingRecords: trackingRecords,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteHomeworkTracking(
      DeleteHomeworkTracking event, Emitter<HomeworkTrackingState> emit) async {
    emit(state.copyWith(status: HomeworkTrackingStatus.loading));
    try {
      await _repository.deleteHomeworkTracking(event.id);
      final trackingRecords = await _repository.getAllHomeworkTracking();
      emit(state.copyWith(
        status: HomeworkTrackingStatus.loaded,
        trackingRecords: trackingRecords,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onBulkUpsertHomeworkTracking(BulkUpsertHomeworkTracking event,
      Emitter<HomeworkTrackingState> emit) async {
    emit(state.copyWith(status: HomeworkTrackingStatus.loading));
    try {
      await _repository.bulkUpsertHomeworkTracking(event.trackingList);
      final trackingRecords = await _repository.getAllHomeworkTracking();
      emit(state.copyWith(
        status: HomeworkTrackingStatus.loaded,
        trackingRecords: trackingRecords,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onBulkGetHomeworkTracking(BulkGetHomeworkTracking event,
      Emitter<HomeworkTrackingState> emit) async {
    emit(state.copyWith(status: HomeworkTrackingStatus.loading));
    try {
      final trackingRecords =
          await _repository.bulkGetHomeworkTracking(event.studentHomeworkIds);
      emit(state.copyWith(
        status: HomeworkTrackingStatus.loaded,
        trackingRecords: trackingRecords,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onBulkGetHomeworkTrackingForHomework(
      BulkGetHomeworkTrackingForHomework event,
      Emitter<HomeworkTrackingState> emit) async {
    emit(state.copyWith(status: HomeworkTrackingStatus.loading));
    try {
      final trackingRecords =
          await _repository.bulkGetHomeworkTrackingForHomework(
              event.studentIds, event.homeworkId);
      emit(state.copyWith(
        status: HomeworkTrackingStatus.loaded,
        trackingRecords: trackingRecords,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearHomeworkTrackingSelection(ClearHomeworkTrackingSelection event,
      Emitter<HomeworkTrackingState> emit) {
    emit(state.copyWith(clearSelectedTracking: true));
  }
}
