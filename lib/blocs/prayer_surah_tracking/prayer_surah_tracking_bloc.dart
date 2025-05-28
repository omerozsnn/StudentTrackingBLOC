import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_tracking/prayer_surah_tracking_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_tracking/prayer_surah_tracking_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_tracking/prayer_surah_tracking_state.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

class PrayerSurahTrackingBloc
    extends Bloc<PrayerSurahTrackingEvent, PrayerSurahTrackingState> {
  final PrayerSurahTrackingRepository repository;
  Student? selectedStudent;
  Uint8List? studentImage;

  PrayerSurahTrackingBloc({required this.repository})
      : super(const PrayerSurahTrackingState()) {
    on<LoadClasses>(_onLoadClasses);
    on<SelectClass>(_onSelectClass);
    on<LoadStudentsWithTrackings>(_onLoadStudentsWithTrackings);
    on<LoadAssignedSurahDua>(_onLoadAssignedSurahDua);
    on<SelectSurahDua>(_onSelectSurahDua);
    on<SelectStudent>(_onSelectStudent);
    on<UpdateStudentTrackingStatus>(_onUpdateStudentTrackingStatus);
    on<UpdateStudentTrackingDegerlendirme>(
        _onUpdateStudentTrackingDegerlendirme);
    on<UpdateStudentTrackingEkGorus>(_onUpdateStudentTrackingEkGorus);
    on<SaveTrackings>(_onSaveTrackings);
    on<LoadStudentPhoto>(_onLoadStudentPhoto);
    on<LoadPreviousTrackings>(_onLoadPreviousTrackings);
  }

  Future<void> _onLoadClasses(
      LoadClasses event, Emitter<PrayerSurahTrackingState> emit) async {
    emit(state.copyWith(status: PrayerSurahTrackingStatus.loading));
    try {
      final classes = await repository.getClasses();
      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.success,
        classes: classes,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSelectClass(
      SelectClass event, Emitter<PrayerSurahTrackingState> emit) async {
    emit(state.copyWith(
      status: PrayerSurahTrackingStatus.loading,
      selectedClass: event.className,
      clearSelectedSurahDuaId: true,
    ));

    try {
      add(LoadStudentsWithTrackings(event.className));
      add(LoadAssignedSurahDua(event.className));
    } catch (e) {
      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadStudentsWithTrackings(LoadStudentsWithTrackings event,
      Emitter<PrayerSurahTrackingState> emit) async {
    emit(state.copyWith(status: PrayerSurahTrackingStatus.loading));
    try {
      final students = await repository.getStudentsByClassName(event.className);
      Map<int, Map<String, dynamic>> trackings = {};

      if (event.surahDuaId != null) {
        trackings =
            await repository.getStudentTrackings(students, event.surahDuaId);
      } else {
        for (var student in students) {
          trackings[student.id] = {
            'durum': 'Okumadı',
            'ekgorus': '',
            'degerlendirme': null,
          };
        }
      }

      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.success,
        students: students,
        studentTrackings: trackings,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadAssignedSurahDua(LoadAssignedSurahDua event,
      Emitter<PrayerSurahTrackingState> emit) async {
    // No need to emit loading state as it might already be in loading state from class selection
    try {
      final surahDuaList =
          await repository.getAssignedSurahDua(event.className);
      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.success,
        assignedSurahDuaList: surahDuaList,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSelectSurahDua(
      SelectSurahDua event, Emitter<PrayerSurahTrackingState> emit) async {
    emit(state.copyWith(
      selectedSurahDuaId: event.surahDuaId,
    ));

    if (state.selectedClass != null) {
      add(LoadStudentsWithTrackings(state.selectedClass!,
          surahDuaId: event.surahDuaId));
    }
  }

  Future<void> _onSelectStudent(
      SelectStudent event, Emitter<PrayerSurahTrackingState> emit) async {
    emit(state.copyWith(status: PrayerSurahTrackingStatus.loading));
    try {
      // Find the student in the current list
      selectedStudent = state.students.firstWhere(
        (student) => student.id == event.studentId,
        orElse: () => throw Exception('Student not found'),
      );

      // Load the student's photo
      add(LoadStudentPhoto(event.studentId));

      // If a surah/dua is selected, load previous trackings
      if (state.selectedSurahDuaId != null) {
        add(LoadPreviousTrackings(event.studentId,
            surahDuaId: state.selectedSurahDuaId));
      }

      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.success,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateStudentTrackingStatus(UpdateStudentTrackingStatus event,
      Emitter<PrayerSurahTrackingState> emit) {
    final Map<int, Map<String, dynamic>> updatedTrackings =
        Map.from(state.studentTrackings);

    if (updatedTrackings.containsKey(event.studentId)) {
      updatedTrackings[event.studentId] = {
        ...updatedTrackings[event.studentId]!,
        'durum': event.durum,
      };
    } else {
      updatedTrackings[event.studentId] = {
        'durum': event.durum,
        'ekgorus': '',
        'degerlendirme': null,
      };
    }

    emit(state.copyWith(studentTrackings: updatedTrackings));
  }

  void _onUpdateStudentTrackingDegerlendirme(
      UpdateStudentTrackingDegerlendirme event,
      Emitter<PrayerSurahTrackingState> emit) {
    final Map<int, Map<String, dynamic>> updatedTrackings =
        Map.from(state.studentTrackings);

    if (updatedTrackings.containsKey(event.studentId)) {
      updatedTrackings[event.studentId] = {
        ...updatedTrackings[event.studentId]!,
        'degerlendirme': event.degerlendirme,
      };
    } else {
      updatedTrackings[event.studentId] = {
        'durum': 'Okumadı',
        'ekgorus': '',
        'degerlendirme': event.degerlendirme,
      };
    }

    emit(state.copyWith(studentTrackings: updatedTrackings));
  }

  void _onUpdateStudentTrackingEkGorus(UpdateStudentTrackingEkGorus event,
      Emitter<PrayerSurahTrackingState> emit) {
    final Map<int, Map<String, dynamic>> updatedTrackings =
        Map.from(state.studentTrackings);

    if (updatedTrackings.containsKey(event.studentId)) {
      updatedTrackings[event.studentId] = {
        ...updatedTrackings[event.studentId]!,
        'ekgorus': event.ekgorus,
      };
    } else {
      updatedTrackings[event.studentId] = {
        'durum': 'Okumadı',
        'ekgorus': event.ekgorus,
        'degerlendirme': null,
      };
    }

    emit(state.copyWith(studentTrackings: updatedTrackings));
  }

  Future<void> _onSaveTrackings(
      SaveTrackings event, Emitter<PrayerSurahTrackingState> emit) async {
    emit(state.copyWith(
      status: PrayerSurahTrackingStatus.loading,
      isSubmitting: true,
    ));

    try {
      List<Student> selectedStudents = state.students
          .where((student) => event.studentIds.contains(student.id))
          .toList();

      await repository.bulkUpdatePrayerSurahTracking(
        selectedStudents,
        event.surahDuaId,
        state.studentTrackings,
      );

      // Reload the data after saving
      if (state.selectedClass != null) {
        add(LoadStudentsWithTrackings(state.selectedClass!,
            surahDuaId: event.surahDuaId));
      }

      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.success,
        isSubmitting: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrayerSurahTrackingStatus.failure,
        errorMessage: e.toString(),
        isSubmitting: false,
      ));
    }
  }

  Future<void> _onLoadStudentPhoto(
      LoadStudentPhoto event, Emitter<PrayerSurahTrackingState> emit) async {
    try {
      studentImage = await repository.getStudentImage(event.studentId);
      emit(state.copyWith(status: PrayerSurahTrackingStatus.success));
    } catch (e) {
      // Don't emit error state for photo loading failures
      // Just log the error
      print('Error loading student photo: $e');
    }
  }

  Future<void> _onLoadPreviousTrackings(LoadPreviousTrackings event,
      Emitter<PrayerSurahTrackingState> emit) async {
    try {
      final previousTrackings = await repository.getPreviousTrackings(
        event.studentId,
        selectedSurahDuaId: event.surahDuaId,
      );

      emit(state.copyWith(
        previousTrackings: previousTrackings,
        status: PrayerSurahTrackingStatus.success,
      ));
    } catch (e) {
      // Don't emit error state for previous trackings failures
      // Just log the error
      print('Error loading previous trackings: $e');
    }
  }
}
