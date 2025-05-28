import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/homework_model.dart';
import 'homework_repository.dart';
import 'homework_event.dart';
import 'homework_state.dart';

class HomeworkBloc extends Bloc<HomeworkEvent, HomeworkState> {
  final HomeworkRepository _homeworkRepository;

  HomeworkBloc({required HomeworkRepository homeworkRepository})
      : _homeworkRepository = homeworkRepository,
        super(const HomeworkState()) {
    on<LoadHomeworks>(_onLoadHomeworks);
    on<AddHomework>(_onAddHomework);
    on<UpdateHomework>(_onUpdateHomework);
    on<DeleteHomework>(_onDeleteHomework);
    on<SelectHomework>(_onSelectHomework);
    on<ClearSelection>(_onClearSelection);
  }

  Future<void> _onLoadHomeworks(
    LoadHomeworks event,
    Emitter<HomeworkState> emit,
  ) async {
    emit(state.copyWith(status: HomeworkStatus.loading));
    try {
      final homeworks = await _homeworkRepository.getAllHomeworks();
      emit(state.copyWith(
        status: HomeworkStatus.loaded,
        homeworks: homeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddHomework(
    AddHomework event,
    Emitter<HomeworkState> emit,
  ) async {
    emit(state.copyWith(status: HomeworkStatus.loading));
    try {
      await _homeworkRepository.addHomework(event.homework);
      final homeworks = await _homeworkRepository.getAllHomeworks();
      emit(state.copyWith(
        status: HomeworkStatus.loaded,
        homeworks: homeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateHomework(
    UpdateHomework event,
    Emitter<HomeworkState> emit,
  ) async {
    emit(state.copyWith(status: HomeworkStatus.loading));
    try {
      await _homeworkRepository.updateHomework(event.homework);
      final homeworks = await _homeworkRepository.getAllHomeworks();
      emit(state.copyWith(
        status: HomeworkStatus.loaded,
        homeworks: homeworks,
        selectedHomework: event.homework,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteHomework(
    DeleteHomework event,
    Emitter<HomeworkState> emit,
  ) async {
    emit(state.copyWith(status: HomeworkStatus.loading));
    try {
      await _homeworkRepository.deleteHomework(event.id);
      final homeworks = await _homeworkRepository.getAllHomeworks();
      emit(state.copyWith(
        status: HomeworkStatus.loaded,
        homeworks: homeworks,
        clearSelectedHomework: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectHomework(
    SelectHomework event,
    Emitter<HomeworkState> emit,
  ) {
    emit(state.copyWith(
      selectedHomework: event.homework,
    ));
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<HomeworkState> emit,
  ) {
    emit(state.copyWith(
      clearSelectedHomework: true,
    ));
  }
}
