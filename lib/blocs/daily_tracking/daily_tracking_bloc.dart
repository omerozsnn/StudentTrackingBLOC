import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:ogrenci_takip_sistemi/blocs/daily_tracking/daily_tracking_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/daily_tracking/daily_tracking_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/daily_tracking/daily_tracking_repository.dart';
import 'package:ogrenci_takip_sistemi/screens/daily_tracking/daily_tracking_screen.dart';
import 'package:ogrenci_takip_sistemi/models/daily_tracking_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';

class DailyTrackingBloc extends Bloc<DailyTrackingEvent, DailyTrackingState> {
  final DailyTrackingRepository repository;
  
  // Internal state variables
  List<Classes> _classes = [];
  int? _currentClassId;
  List<Student> _students = [];
  Map<int, Map<String, Map<EnumCourse, int>>> _trackingData = {};
  Map<int, Map<int, Map<EnumCourse, int>>> _weeklyData = {};
  DateTime _selectedMonth = DateTime.now();
  Map<int, bool> _expandedStudents = {};
  final Map<String, Timer> _debounceTimers = {};

  DailyTrackingBloc({required this.repository}) : super(DailyTrackingInitial()) {
    on<LoadClasses>(_onLoadClasses);
    on<SelectClass>(_onSelectClass);
    on<LoadStudents>(_onLoadStudents);
    on<LoadTrackingData>(_onLoadTrackingData);
    on<ChangeMonth>(_onChangeMonth);
    on<SaveTrackingData>(_onSaveTrackingData);
    on<ToggleStudentExpansion>(_onToggleStudentExpansion);
    on<RefreshData>(_onRefreshData);
    on<ResetDailyTracking>(_onResetDailyTracking);
  }

  @override
  Future<void> close() {
    // Cancel all debounce timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    return super.close();
  }

  // Load classes
  Future<void> _onLoadClasses(
      LoadClasses event, Emitter<DailyTrackingState> emit) async {
    emit(DailyTrackingLoading());
    try {
      _classes = await repository.getClasses();
      
      if (_classes.isNotEmpty) {
        // Set first class as default if no class is selected
        if (_currentClassId == null || 
            !_classes.any((c) => c.id == _currentClassId)) {
          _currentClassId = _classes.first.id;
        }
      } else {
        _currentClassId = null;
      }

      emit(ClassesLoaded(_classes));
    } catch (e) {
      debugPrint('Error loading classes: $e');
      emit(DailyTrackingError('Sınıflar yüklenirken hata oluştu: $e'));
    }
  }

  // Select class
  Future<void> _onSelectClass(
      SelectClass event, Emitter<DailyTrackingState> emit) async {
    _currentClassId = event.classId;
    
    // Reset related data when class changes
    _students = [];
    _trackingData = {};
    _weeklyData = {};
    _expandedStudents = {};

    emit(DailyTrackingLoading());
    
    // Load students for the selected class
    add(LoadStudents(event.classId));
  }

  // Load students
  Future<void> _onLoadStudents(
      LoadStudents event, Emitter<DailyTrackingState> emit) async {
    try {
      _students = await repository.getStudentsByClass(event.classId);
      
      // Initialize expanded students state
      for (final student in _students) {
        _expandedStudents.putIfAbsent(student.id, () => true);
      }

      emit(StudentsLoaded(_students, event.classId));
      
      // Automatically load tracking data after students are loaded
      if (_students.isNotEmpty) {
        add(LoadTrackingData(event.classId, _selectedMonth));
      }
    } catch (e) {
      debugPrint('Error loading students: $e');
      emit(DailyTrackingError('Öğrenciler yüklenirken hata oluştu: $e'));
    }
  }

  // Load tracking data
  Future<void> _onLoadTrackingData(
      LoadTrackingData event, Emitter<DailyTrackingState> emit) async {
    if (_students.isEmpty) {
      emit(TrackingDataLoaded(
        classes: _classes,
        currentClassId: _currentClassId,
        students: _students,
        trackingData: _trackingData,
        weeklyData: _weeklyData,
        selectedMonth: _selectedMonth,
        expandedStudents: _expandedStudents,
      ));
      return;
    }

    try {
      // Calculate date ranges
      final startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime(event.selectedMonth.year, event.selectedMonth.month, 1));
      final lastDay = DateTime(event.selectedMonth.year, event.selectedMonth.month + 1, 0).day;
      final endDate = DateFormat('yyyy-MM-dd')
          .format(DateTime(event.selectedMonth.year, event.selectedMonth.month, lastDay));

      // Extended range for weeks spanning month boundaries
      DateTime extendedStartDate = 
          DateTime(event.selectedMonth.year, event.selectedMonth.month, 1);
      while (extendedStartDate.weekday != DateTime.monday) {
        extendedStartDate = extendedStartDate.subtract(const Duration(days: 1));
      }

      DateTime extendedEndDate =
          DateTime(event.selectedMonth.year, event.selectedMonth.month + 1, 0);
      while (extendedEndDate.weekday != DateTime.sunday) {
        extendedEndDate = extendedEndDate.add(const Duration(days: 1));
      }

      final extStartDateStr = DateFormat('yyyy-MM-dd').format(extendedStartDate);
      final extEndDateStr = DateFormat('yyyy-MM-dd').format(extendedEndDate);

      // Initialize data structures
      _trackingData = {};
      _weeklyData = {};

      // Get days in month
      final daysInMonth = _getDaysInMonth(event.selectedMonth);

      // Initialize data for all students
      for (final student in _students) {
        _trackingData[student.id] = {};
        _weeklyData[student.id] = {};

        // Initialize daily data
        for (final day in daysInMonth) {
          final dateStr = DateFormat('yyyy-MM-dd').format(day);
          _trackingData[student.id]![dateStr] = {};

          for (final course in EnumCourse.values) {
            _trackingData[student.id]![dateStr]![course] = 0;
          }

          final weekOfYear = _getWeekOfYear(day);
          _weeklyData[student.id]![weekOfYear] ??= {};

          for (final course in EnumCourse.values) {
            _weeklyData[student.id]![weekOfYear]![course] ??= 0;
          }
        }
      }

      // Load actual data
      final allTrackingData = await repository.getTrackingDataByDateRange(
          extStartDateStr, extEndDateStr);

      // Process the tracking data
      for (final tracking in allTrackingData) {
        if (tracking.date == null || !_trackingData.containsKey(tracking.ogrenciId)) {
          continue;
        }

        final studentId = tracking.ogrenciId;
        final parsedDate = tracking.date;
        final course = tracking.course;
        final questionCount = tracking.solvedQuestions ?? 0;
        final weekOfYear = _getWeekOfYear(parsedDate);

        // Update daily data for current month
        if (parsedDate.year == event.selectedMonth.year &&
            parsedDate.month == event.selectedMonth.month) {
          final dateStr = DateFormat('yyyy-MM-dd').format(parsedDate);
          if (_trackingData[studentId]!.containsKey(dateStr)) {
            _trackingData[studentId]![dateStr]![course] = questionCount;
          }
        }

        // Update weekly data (for extended range)
        if (!_weeklyData[studentId]!.containsKey(weekOfYear)) {
          _weeklyData[studentId]![weekOfYear] = {};
          for (final c in EnumCourse.values) {
            _weeklyData[studentId]![weekOfYear]![c] = 0;
          }
        }

        _weeklyData[studentId]![weekOfYear]![course] =
            (_weeklyData[studentId]![weekOfYear]![course] ?? 0) + questionCount;
      }

      emit(TrackingDataLoaded(
        classes: _classes,
        currentClassId: _currentClassId,
        students: _students,
        trackingData: _trackingData,
        weeklyData: _weeklyData,
        selectedMonth: event.selectedMonth,
        expandedStudents: _expandedStudents,
      ));

    } catch (e) {
      debugPrint('Error loading tracking data: $e');
      emit(DailyTrackingError('Takip verileri yüklenirken hata oluştu: $e'));
    }
  }

  // Change month
  Future<void> _onChangeMonth(
      ChangeMonth event, Emitter<DailyTrackingState> emit) async {
    _selectedMonth = DateTime(
        _selectedMonth.year, _selectedMonth.month + event.monthDelta, 1);

    if (_currentClassId != null) {
      add(LoadTrackingData(_currentClassId!, _selectedMonth));
    }
  }

  // Save tracking data with debouncing
  Future<void> _onSaveTrackingData(
      SaveTrackingData event, Emitter<DailyTrackingState> emit) async {
    if (_currentClassId == null) return;

    final resolvedValue = event.value ?? 0;
    final key = '${event.studentId}-${DateFormat('yyyy-MM-dd').format(event.date)}-${event.course.toString()}';

    // Cancel previous timer for this key
    _debounceTimers[key]?.cancel();

    // Create new debounced timer
    _debounceTimers[key] = Timer(const Duration(milliseconds: 500), () async {
      try {
        // Save to repository
        await repository.saveTrackingData(DailyTracking(
          id: 0,
          date: event.date,
          course: event.course,
          solvedQuestions: resolvedValue,
          sinifId: _currentClassId!,
          ogrenciId: event.studentId,
        ));

        // Update local data
        final dateStr = DateFormat('yyyy-MM-dd').format(event.date);
        final oldValue = _trackingData[event.studentId]?[dateStr]?[event.course] ?? 0;

        // Update daily data
        _trackingData[event.studentId] ??= {};
        _trackingData[event.studentId]![dateStr] ??= {};
        _trackingData[event.studentId]![dateStr]![event.course] = resolvedValue;

        // Update weekly data
        final weekOfYear = _getWeekOfYear(event.date);
        _weeklyData[event.studentId] ??= {};
        _weeklyData[event.studentId]![weekOfYear] ??= {};

        final valueDiff = resolvedValue - oldValue;
        final currentWeekTotal = _weeklyData[event.studentId]![weekOfYear]![event.course] ?? 0;
        _weeklyData[event.studentId]![weekOfYear]![event.course] = currentWeekTotal + valueDiff;

        // Emit updated state
        emit(TrackingDataLoaded(
          classes: _classes,
          currentClassId: _currentClassId,
          students: _students,
          trackingData: _trackingData,
          weeklyData: _weeklyData,
          selectedMonth: _selectedMonth,
          expandedStudents: _expandedStudents,
        ));

        // Show success message
        emit(DailyTrackingOperationSuccess('Veri başarıyla kaydedildi'));

        // Return to main state
        emit(TrackingDataLoaded(
          classes: _classes,
          currentClassId: _currentClassId,
          students: _students,
          trackingData: _trackingData,
          weeklyData: _weeklyData,
          selectedMonth: _selectedMonth,
          expandedStudents: _expandedStudents,
        ));

      } catch (e) {
        debugPrint('Error saving tracking data: $e');
        emit(DailyTrackingError('Veri kaydedilirken hata oluştu: $e'));
      } finally {
        _debounceTimers.remove(key);
      }
    });
  }

  // Toggle student expansion
  void _onToggleStudentExpansion(
      ToggleStudentExpansion event, Emitter<DailyTrackingState> emit) {
    _expandedStudents[event.studentId] = !(_expandedStudents[event.studentId] ?? true);

    emit(TrackingDataLoaded(
      classes: _classes,
      currentClassId: _currentClassId,
      students: _students,
      trackingData: _trackingData,
      weeklyData: _weeklyData,
      selectedMonth: _selectedMonth,
      expandedStudents: _expandedStudents,
    ));
  }

  // Refresh data
  Future<void> _onRefreshData(
      RefreshData event, Emitter<DailyTrackingState> emit) async {
    if (_currentClassId != null) {
      add(LoadTrackingData(_currentClassId!, _selectedMonth));
    } else {
      add(LoadClasses());
    }
  }

  // Reset daily tracking
  void _onResetDailyTracking(
      ResetDailyTracking event, Emitter<DailyTrackingState> emit) {
    _classes = [];
    _currentClassId = null;
    _students = [];
    _trackingData = {};
    _weeklyData = {};
    _selectedMonth = DateTime.now();
    _expandedStudents = {};

    // Cancel all timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    emit(DailyTrackingInitial());
  }

  // Helper methods
  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDay.day,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  int _getWeekOfYear(DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();

    if (woy < 1) {
      DateTime prevYearLastDay = DateTime(date.year - 1, 12, 31);
      return _getWeekOfYear(prevYearLastDay);
    } else if (woy > 52) {
      DateTime lastDay = DateTime(date.year, 12, 31);
      if (lastDay.weekday < 4) {
        return 1;
      }
    }
    return woy;
  }
} 