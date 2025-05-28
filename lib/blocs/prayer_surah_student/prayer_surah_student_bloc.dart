import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart';
import 'package:ogrenci_takip_sistemi/api.dart/studentControlApi.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_student/prayer_surah_student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_student/prayer_surah_student_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_student/prayer_surah_student_state.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_student_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

class PrayerSurahStudentBloc
    extends Bloc<PrayerSurahStudentEvent, PrayerSurahStudentState> {
  final PrayerSurahStudentRepository repository;
  final StudentApiService studentApiService;
  final ApiService classApiService;

  PrayerSurahStudentBloc({
    required this.repository,
    required this.studentApiService,
    required this.classApiService,
  }) : super(const PrayerSurahStudentState()) {
    on<LoadPrayerSurahStudents>(_onLoadPrayerSurahStudents);
    on<LoadPrayerSurahStudentsByStudentId>(
        _onLoadPrayerSurahStudentsByStudentId);
    on<LoadPrayerSurahStudentsByClassId>(_onLoadPrayerSurahStudentsByClassId);
    on<AddPrayerSurahStudent>(_onAddPrayerSurahStudent);
    on<UpdatePrayerSurahStudent>(_onUpdatePrayerSurahStudent);
    on<DeletePrayerSurahStudent>(_onDeletePrayerSurahStudent);
    on<AssignPrayerSurahToMultipleStudents>(
        _onAssignPrayerSurahToMultipleStudents);
    on<SetSelectedPrayerSurahId>(_onSetSelectedPrayerSurahId);
    on<SetSelectedClass>(_onSetSelectedClass);
    on<SelectAllStudents>(_onSelectAllStudents);
    on<ToggleStudentSelection>(_onToggleStudentSelection);
  }

  Future<void> _onLoadPrayerSurahStudents(
    LoadPrayerSurahStudents event,
    Emitter<PrayerSurahStudentState> emit,
  ) async {
    emit(state.copyWith(status: PrayerSurahStudentStatus.loading));
    try {
      final prayerSurahStudents = await repository.getAllPrayerSurahStudents();
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.success,
          prayerSurahStudents: prayerSurahStudents,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadPrayerSurahStudentsByStudentId(
    LoadPrayerSurahStudentsByStudentId event,
    Emitter<PrayerSurahStudentState> emit,
  ) async {
    emit(state.copyWith(status: PrayerSurahStudentStatus.loading));
    try {
      final prayerSurahStudents =
          await repository.getPrayerSurahStudentByStudentId(event.studentId);
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.success,
          prayerSurahStudents: prayerSurahStudents,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadPrayerSurahStudentsByClassId(
    LoadPrayerSurahStudentsByClassId event,
    Emitter<PrayerSurahStudentState> emit,
  ) async {
    emit(state.copyWith(status: PrayerSurahStudentStatus.loading));
    try {
      final prayerSurahStudents =
          await repository.getPrayerSurahStudentByClassId(event.classId);
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.success,
          prayerSurahStudents: prayerSurahStudents,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddPrayerSurahStudent(
    AddPrayerSurahStudent event,
    Emitter<PrayerSurahStudentState> emit,
  ) async {
    emit(state.copyWith(status: PrayerSurahStudentStatus.loading));
    try {
      final prayerSurahStudent =
          await repository.addPrayerSurahStudent(event.prayerSurahStudent);
      final updatedPrayerSurahStudents =
          List<PrayerSurahStudent>.from(state.prayerSurahStudents)
            ..add(prayerSurahStudent);
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.success,
          prayerSurahStudents: updatedPrayerSurahStudents,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePrayerSurahStudent(
    UpdatePrayerSurahStudent event,
    Emitter<PrayerSurahStudentState> emit,
  ) async {
    emit(state.copyWith(status: PrayerSurahStudentStatus.loading));
    try {
      final updatedPrayerSurahStudent =
          await repository.updatePrayerSurahStudent(
        event.id,
        event.prayerSurahStudent,
      );
      final updatedPrayerSurahStudents =
          state.prayerSurahStudents.map((prayerSurahStudent) {
        if (prayerSurahStudent.id == event.id) {
          return updatedPrayerSurahStudent;
        }
        return prayerSurahStudent;
      }).toList();
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.success,
          prayerSurahStudents: updatedPrayerSurahStudents,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeletePrayerSurahStudent(
    DeletePrayerSurahStudent event,
    Emitter<PrayerSurahStudentState> emit,
  ) async {
    emit(state.copyWith(status: PrayerSurahStudentStatus.loading));
    try {
      final success = await repository.deletePrayerSurahStudent(event.id);
      if (success) {
        final updatedPrayerSurahStudents = state.prayerSurahStudents
            .where((prayerSurahStudent) => prayerSurahStudent.id != event.id)
            .toList();
        emit(
          state.copyWith(
            status: PrayerSurahStudentStatus.success,
            prayerSurahStudents: updatedPrayerSurahStudents,
            clearError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAssignPrayerSurahToMultipleStudents(
    AssignPrayerSurahToMultipleStudents event,
    Emitter<PrayerSurahStudentState> emit,
  ) async {
    if (event.prayerSurahId == null || event.studentIds.isEmpty) {
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.failure,
          errorMessage:
              'Please select a prayer/surah and at least one student.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: PrayerSurahStudentStatus.loading));
    try {
      final success = await repository.assignPrayerSurahToMultipleStudents(
        event.prayerSurahId,
        event.studentIds,
      );
      if (success) {
        emit(
          state.copyWith(
            status: PrayerSurahStudentStatus.success,
            clearError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStudentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSetSelectedPrayerSurahId(
    SetSelectedPrayerSurahId event,
    Emitter<PrayerSurahStudentState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPrayerSurahId: event.prayerSurahId,
      ),
    );
  }

  Future<void> _onSetSelectedClass(
    SetSelectedClass event,
    Emitter<PrayerSurahStudentState> emit,
  ) async {
    emit(state.copyWith(
      status: PrayerSurahStudentStatus.loading,
      selectedClass: event.className,
    ));

    if (event.className != null) {
      try {
        final students =
            await studentApiService.getStudentsByClassName(event.className!);

        // Reset student selections when class changes
        Map<int, bool> selections = {};
        for (var student in students) {
          selections[student.id] = state.selectAll;
        }

        emit(
          state.copyWith(
            status: PrayerSurahStudentStatus.success,
            students: students,
            selectedStudents: selections,
            clearError: true,
          ),
        );
      } catch (e) {
        debugPrint('Failed to load students for class: $e');
        emit(
          state.copyWith(
            status: PrayerSurahStudentStatus.failure,
            errorMessage: 'Failed to load students for class: $e',
          ),
        );
      }
    }
  }

  void _onSelectAllStudents(
    SelectAllStudents event,
    Emitter<PrayerSurahStudentState> emit,
  ) {
    Map<int, bool> selections = {};
    for (var student in state.students) {
      selections[student.id] = event.selectAll;
    }

    emit(
      state.copyWith(
        selectAll: event.selectAll,
        selectedStudents: selections,
      ),
    );
  }

  void _onToggleStudentSelection(
    ToggleStudentSelection event,
    Emitter<PrayerSurahStudentState> emit,
  ) {
    final updatedSelections = Map<int, bool>.from(state.selectedStudents);
    updatedSelections[event.studentId] = event.isSelected;

    // Check if all students are selected to update the selectAll flag
    final allSelected = state.students.every(
      (student) => updatedSelections[student.id] == true,
    );

    emit(
      state.copyWith(
        selectedStudents: updatedSelections,
        selectAll: allSelected,
      ),
    );
  }
}
