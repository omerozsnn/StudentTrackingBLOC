import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_state.dart';
import 'package:ogrenci_takip_sistemi/models/grades_model.dart';
import 'package:flutter/foundation.dart';

class GradesBloc extends Bloc<GradesEvent, GradesState> {
  final GradesRepository repository;
  List<Grade> grades = [];
  int? selectedCourseClassId;
  int selectedSemester = 1;

  GradesBloc({required this.repository}) : super(GradesInitial()) {
    on<LoadGradesByCourseClass>(_onLoadGradesByCourseClass);
    on<LoadGradesBySemester>(_onLoadGradesBySemester);
    on<UpdateGrade>(_onUpdateGrade);
    on<CreateGrade>(_onCreateGrade);
    on<DeleteGrade>(_onDeleteGrade);
    on<UploadExcelGrades>(_onUploadExcelGrades);
    on<SetSelectedCourseClass>(_onSetSelectedCourseClass);
    on<SetSelectedSemester>(_onSetSelectedSemester);
  }

  Future<void> _onLoadGradesByCourseClass(
      LoadGradesByCourseClass event, Emitter<GradesState> emit) async {
    if (event.courseClassId == null) {
      emit(GradesLoaded([])); // Empty grades if no course class selected
      return;
    }

    emit(GradesLoading());
    try {
      selectedCourseClassId = event.courseClassId;
      selectedSemester = event.semester;

      final loadedGrades = await repository.getGradesBySemester(
        event.courseClassId!,
        event.semester,
      );

      grades = loadedGrades;
      emit(GradesLoaded(grades));
    } catch (e) {
      debugPrint('Error loading grades: $e');

      // Check if it's a 404 error (no grades found)
      if (e.toString().contains('404')) {
        // Just emit empty grades instead of an error
        grades = [];
        emit(GradesLoaded(grades));
      } else {
        // For other errors, emit the error state
        emit(GradesError('Notlar yüklenirken hata oluştu: $e'));
      }
    }
  }

  Future<void> _onLoadGradesBySemester(
      LoadGradesBySemester event, Emitter<GradesState> emit) async {
    if (selectedCourseClassId == null) {
      emit(GradesError('Önce sınıf ve ders seçmelisiniz'));
      return;
    }

    emit(GradesLoading());
    try {
      selectedSemester = event.semester;

      final loadedGrades = await repository.getGradesBySemester(
        selectedCourseClassId!,
        event.semester,
      );

      grades = loadedGrades;
      emit(GradesLoaded(grades));
    } catch (e) {
      debugPrint('Error loading grades by semester: $e');

      // Check if it's a 404 error (no grades found)
      if (e.toString().contains('404')) {
        // Just emit empty grades instead of an error
        grades = [];
        emit(GradesLoaded(grades));
      } else {
        // For other errors, emit the error state
        emit(GradesError('Notlar yüklenirken hata oluştu: $e'));
      }
    }
  }

  Future<void> _onUpdateGrade(
      UpdateGrade event, Emitter<GradesState> emit) async {
    emit(GradesLoading());
    try {
      final updatedGrade = await repository.updateGrade(
        event.gradeId,
        event.grade,
      );

      // Update the grade in the local list
      final index = grades.indexWhere((g) => g.id == updatedGrade.id);
      if (index != -1) {
        grades[index] = updatedGrade;
      }

      emit(GradeOperationSuccess('Not başarıyla güncellendi'));
      emit(GradesLoaded(grades));
    } catch (e) {
      debugPrint('Error updating grade: $e');
      emit(GradesError('Not güncellenirken hata oluştu: $e'));
    }
  }

  Future<void> _onCreateGrade(
      CreateGrade event, Emitter<GradesState> emit) async {
    emit(GradesLoading());
    try {
      final newGrade = await repository.createGrade(event.grade);

      // Add the new grade to the local list
      grades.add(newGrade);

      emit(GradeOperationSuccess('Not başarıyla eklendi'));
      emit(GradesLoaded(grades));
    } catch (e) {
      debugPrint('Error creating grade: $e');
      emit(GradesError('Not eklenirken hata oluştu: $e'));
    }
  }

  Future<void> _onDeleteGrade(
      DeleteGrade event, Emitter<GradesState> emit) async {
    emit(GradesLoading());
    try {
      await repository.deleteGrade(event.gradeId);

      // Remove the grade from the local list
      grades.removeWhere((g) => g.id == event.gradeId);

      emit(GradeOperationSuccess('Not başarıyla silindi'));
      emit(GradesLoaded(grades));
    } catch (e) {
      debugPrint('Error deleting grade: $e');
      emit(GradesError('Not silinirken hata oluştu: $e'));
    }
  }

  Future<void> _onUploadExcelGrades(
      UploadExcelGrades event, Emitter<GradesState> emit) async {
    if (selectedCourseClassId == null) {
      emit(GradesError('Önce sınıf ve ders seçmelisiniz'));
      return;
    }

    emit(GradesLoading());
    try {
      await repository.uploadExcelGrades(
        event.excelFile,
        selectedCourseClassId!,
        selectedSemester,
      );

      // Reload the grades after Excel upload
      final loadedGrades = await repository.getGradesBySemester(
        selectedCourseClassId!,
        selectedSemester,
      );

      grades = loadedGrades;

      emit(GradeOperationSuccess('Excel notları başarıyla yüklendi'));
      emit(GradesLoaded(grades));
    } catch (e) {
      debugPrint('Error uploading Excel grades: $e');
      emit(GradesError('Excel notları yüklenirken hata oluştu: $e'));
    }
  }

  void _onSetSelectedCourseClass(
      SetSelectedCourseClass event, Emitter<GradesState> emit) {
    selectedCourseClassId = event.courseClassId;
    // Don't make API calls here - let the screen handle API calls explicitly
  }

  void _onSetSelectedSemester(
      SetSelectedSemester event, Emitter<GradesState> emit) {
    selectedSemester = event.semester;
    // Don't call LoadGradesBySemester here as it creates an infinite loop
    // The GradeTrackingScreen will explicitly call LoadGradesByCourseClass when needed
  }
}
