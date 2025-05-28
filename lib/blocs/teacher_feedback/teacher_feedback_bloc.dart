import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_feedback/teacher_feedback_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_feedback/teacher_feedback_state.dart'
    as states;
import 'package:ogrenci_takip_sistemi/api.dart/teacher_feedback_repository.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';

class TeacherFeedbackBloc
    extends Bloc<TeacherFeedbackEvent, states.TeacherFeedbackState> {
  final TeacherFeedbackRepository repository;

  TeacherFeedbackBloc({required this.repository})
      : super(states.TeacherFeedbackInitial()) {
    on<LoadTeacherFeedbackOptions>(_onLoadTeacherFeedbackOptions);
    on<AddTeacherFeedbackOption>(_onAddTeacherFeedbackOption);
    on<UpdateTeacherFeedbackOption>(_onUpdateTeacherFeedbackOption);
    on<DeleteTeacherFeedbackOption>(_onDeleteTeacherFeedbackOption);
    on<SelectTeacherFeedbackOption>(_onSelectTeacherFeedbackOption);
    on<ClearSelectedTeacherFeedbackOption>(
        _onClearSelectedTeacherFeedbackOption);
    on<TeacherFeedbackLoading>(_onTeacherFeedbackLoading);
  }

  Future<void> _onLoadTeacherFeedbackOptions(LoadTeacherFeedbackOptions event,
      Emitter<states.TeacherFeedbackState> emit) async {
    emit(states.TeacherFeedbackLoading());
    try {
      final options = await repository.getTeacherFeedbackOptions();
      emit(states.TeacherFeedbackOptionsLoaded(options));
    } catch (e) {
      emit(states.TeacherFeedbackError('Öğretmen görüşleri yüklenemedi: $e'));
    }
  }

  Future<void> _onAddTeacherFeedbackOption(AddTeacherFeedbackOption event,
      Emitter<states.TeacherFeedbackState> emit) async {
    emit(states.TeacherFeedbackLoading());
    try {
      await repository.addTeacherFeedbackOption(event.gorusMetni);
      emit(const states.TeacherFeedbackOperationSuccess(
          'Görüş başarıyla eklendi'));

      // Reload options
      final options = await repository.getTeacherFeedbackOptions();
      emit(states.TeacherFeedbackOptionsLoaded(options));
    } catch (e) {
      emit(states.TeacherFeedbackError('Görüş eklenemedi: $e'));
    }
  }

  Future<void> _onUpdateTeacherFeedbackOption(UpdateTeacherFeedbackOption event,
      Emitter<states.TeacherFeedbackState> emit) async {
    if (state is states.TeacherFeedbackOptionsLoaded) {
      emit(states.TeacherFeedbackLoading());
      try {
        await repository.updateTeacherFeedbackOption(
            event.id, event.gorusMetni);
        emit(const states.TeacherFeedbackOperationSuccess(
            'Görüş başarıyla güncellendi'));

        // Reload options
        final options = await repository.getTeacherFeedbackOptions();
        emit(states.TeacherFeedbackOptionsLoaded(options));
      } catch (e) {
        emit(states.TeacherFeedbackError('Görüş güncellenemedi: $e'));
      }
    }
  }

  Future<void> _onDeleteTeacherFeedbackOption(DeleteTeacherFeedbackOption event,
      Emitter<states.TeacherFeedbackState> emit) async {
    if (state is states.TeacherFeedbackOptionsLoaded) {
      emit(states.TeacherFeedbackLoading());
      try {
        await repository.deleteTeacherFeedbackOption(event.id);
        emit(const states.TeacherFeedbackOperationSuccess(
            'Görüş başarıyla silindi'));

        // Reload options
        final options = await repository.getTeacherFeedbackOptions();
        emit(states.TeacherFeedbackOptionsLoaded(options));
      } catch (e) {
        emit(states.TeacherFeedbackError('Görüş silinemedi: $e'));
      }
    }
  }

  void _onSelectTeacherFeedbackOption(SelectTeacherFeedbackOption event,
      Emitter<states.TeacherFeedbackState> emit) {
    if (state is states.TeacherFeedbackOptionsLoaded) {
      final currentState = state as states.TeacherFeedbackOptionsLoaded;
      final selectedOption = currentState.options.firstWhere(
          (option) => option.id == event.id,
          orElse: () => throw Exception('Seçilen görüş bulunamadı'));

      emit(currentState.copyWith(selectedOption: selectedOption));
    }
  }

  void _onClearSelectedTeacherFeedbackOption(
      ClearSelectedTeacherFeedbackOption event,
      Emitter<states.TeacherFeedbackState> emit) {
    if (state is states.TeacherFeedbackOptionsLoaded) {
      final currentState = state as states.TeacherFeedbackOptionsLoaded;
      emit(currentState.copyWith(clearSelection: true));
    }
  }

  void _onTeacherFeedbackLoading(
      TeacherFeedbackLoading event, Emitter<states.TeacherFeedbackState> emit) {
    emit(states.TeacherFeedbackLoading());
  }
}
