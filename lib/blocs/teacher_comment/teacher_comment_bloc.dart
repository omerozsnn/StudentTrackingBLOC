import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_repository.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';

class TeacherCommentBloc
    extends Bloc<TeacherCommentEvent, TeacherCommentState> {
  final TeacherCommentRepository repository;

  // State tracking variables
  String? _selectedClass;
  List<Student> _students = [];
  Student? _selectedStudent;
  Set<Student> _selectedStudents = {};
  List<TeacherFeedbackOption> _feedbackOptions = [];
  Set<int> _selectedFeedbackOptionIds = {};
  bool _isMultiSelectMode = false;

  // Public getter for feedback options
  List<TeacherFeedbackOption> get feedbackOptions => _feedbackOptions;

  TeacherCommentBloc({required this.repository})
      : super(TeacherCommentInitial()) {
    on<LoadClassesEvent>(_onLoadClasses);
    on<LoadStudentsByClassEvent>(_onLoadStudentsByClass);
    on<SelectStudentEvent>(_onSelectStudent);
    on<ClearSelectedStudentEvent>(_onClearSelectedStudent);
    on<LoadFeedbackOptionsEvent>(_onLoadFeedbackOptions);
    on<LoadStudentFeedbackEvent>(_onLoadStudentFeedback);
    on<AddFeedbackEvent>(_onAddFeedback);
    on<DeleteFeedbackEvent>(_onDeleteFeedback);
    on<UpdateSelectedStudentsEvent>(_onUpdateSelectedStudents);
    on<UpdateSelectedFeedbackOptionsEvent>(_onUpdateSelectedFeedbackOptions);
    on<AddBulkFeedbackEvent>(_onAddBulkFeedback);
    on<ToggleMultiSelectModeEvent>(_onToggleMultiSelectMode);

    // Load feedback options immediately at initialization
    add(LoadFeedbackOptionsEvent());
  }

  Future<void> _onLoadClasses(
      LoadClassesEvent event, Emitter<TeacherCommentState> emit) async {
    emit(TeacherCommentLoading());
    try {
      final classes = await repository.getClassesForDropdown();
      emit(ClassesLoadedState(classes: classes, selectedClass: _selectedClass));

      // If there's a selected class, load its students
      if (_selectedClass != null) {
        add(LoadStudentsByClassEvent(_selectedClass!));
      }
    } catch (e) {
      emit(TeacherCommentError('Failed to load classes: $e'));
    }
  }

  Future<void> _onLoadStudentsByClass(
      LoadStudentsByClassEvent event, Emitter<TeacherCommentState> emit) async {
    // Store old state so we can restore class list if loading fails
    final previousState = state;

    // First emit a students loading state but maintain the classes
    if (previousState is ClassesLoadedState) {
      emit(StudentsLoadingState(
        classes: previousState.classes,
        selectedClass: event.className,
      ));
    } else {
      emit(TeacherCommentLoading());
    }

    try {
      _selectedClass = event.className;
      _students = await repository.getStudentsByClassName(event.className);
      _selectedStudent = null; // Clear selected student when class changes

      emit(StudentsLoadedState(
        students: _students,
        selectedClass: _selectedClass!,
        selectedStudent: _selectedStudent,
        selectedStudents: _selectedStudents,
        isMultiSelectMode: _isMultiSelectMode,
      ));

      // Load feedback options
      add(LoadFeedbackOptionsEvent());
    } catch (e) {
      print('Error loading students by class: $e');

      // If loading failed, restore previous class list if available
      if (previousState is ClassesLoadedState) {
        emit(ClassesLoadedState(
            classes: previousState.classes,
            selectedClass: previousState.selectedClass));
      }

      emit(TeacherCommentError('Öğrenciler yüklenemedi: $e'));
    }
  }

  void _onSelectStudent(
      SelectStudentEvent event, Emitter<TeacherCommentState> emit) {
    print(
        'BLOC: Selecting student with ID: ${event.student.id} (${event.student.adSoyad})');

    // Update selected student
    _selectedStudent = event.student;

    // Check if we already have feedback loaded for this student
    final currentState = state;
    final hasCachedFeedback = currentState is StudentFeedbackLoadedState &&
        currentState.studentId == event.student.id;

    // Make sure we have feedback options loaded first
    if (_feedbackOptions.isEmpty) {
      print('BLOC: Loading feedback options because none are available');
      add(LoadFeedbackOptionsEvent());
    } else {
      // Always emit the feedback options state to ensure the UI has access to them
      print('BLOC: Emitting feedback options: ${_feedbackOptions.length}');
      emit(FeedbackOptionsLoadedState(
        options: _feedbackOptions,
        selectedOptionIds: _selectedFeedbackOptionIds,
      ));
    }

    // Emit the students loaded state with the selected student
    print(
        'BLOC: Emitting StudentsLoadedState with selected student: ${_selectedStudent?.adSoyad}');
    emit(StudentsLoadedState(
      students: _students,
      selectedClass: _selectedClass!,
      selectedStudent: _selectedStudent,
      selectedStudents: _selectedStudents,
      isMultiSelectMode: _isMultiSelectMode,
    ));

    // Load student feedback if not already cached
    if (!hasCachedFeedback) {
      print('BLOC: Loading student feedback for: ${event.student.id}');
      add(LoadStudentFeedbackEvent(_selectedStudent!.id));
    } else {
      // Re-emit the cached feedback to ensure UI is consistent
      if (currentState is StudentFeedbackLoadedState) {
        print('BLOC: Re-emitting cached feedback for: ${event.student.id}');
        emit(currentState);
      }
    }
  }

  void _onClearSelectedStudent(
      ClearSelectedStudentEvent event, Emitter<TeacherCommentState> emit) {
    _selectedStudent = null;

    emit(StudentsLoadedState(
      students: _students,
      selectedClass: _selectedClass!,
      selectedStudent: null,
      selectedStudents: _selectedStudents,
      isMultiSelectMode: _isMultiSelectMode,
    ));
  }

  Future<void> _onLoadFeedbackOptions(
      LoadFeedbackOptionsEvent event, Emitter<TeacherCommentState> emit) async {
    try {
      _feedbackOptions = await repository.getFeedbackOptions();

      // Debug output
      print('Loaded feedback options: ${_feedbackOptions.length}');
      _feedbackOptions.forEach((option) {
        print('Option ${option.id}: ${option.gorusMetni}');
      });

      emit(FeedbackOptionsLoadedState(
        options: _feedbackOptions,
        selectedOptionIds: _selectedFeedbackOptionIds,
      ));
    } catch (e) {
      print('Error loading feedback options: $e');
      emit(TeacherCommentError('Failed to load feedback options: $e'));
    }
  }

  Future<void> _onLoadStudentFeedback(
      LoadStudentFeedbackEvent event, Emitter<TeacherCommentState> emit) async {
    // Check if we already have feedback loaded for this student
    final currentState = state;
    final hasCachedEmptyFeedback = currentState is StudentFeedbackLoadedState &&
        currentState.studentId == event.studentId;

    // If we already have feedback for this student (empty or not), just reuse it
    if (hasCachedEmptyFeedback) {
      // Re-emit the same state to ensure UI is updated
      if (currentState is StudentFeedbackLoadedState) {
        emit(currentState);
        return;
      }
    }

    // Only emit loading if we need to fetch new data
    emit(StudentFeedbackLoadedState(
      studentId: event.studentId,
      feedbackList: [],
    ));

    try {
      final feedbackList = await repository.getStudentFeedback(event.studentId);

      // Print some debug info about the received feedback
      print('Received feedback for student ${event.studentId}');
      print('Number of feedback items: ${feedbackList.length}');

      // Always emit the loaded state, even with empty list
      emit(StudentFeedbackLoadedState(
        studentId: event.studentId,
        feedbackList: feedbackList,
      ));

      // Also emit the options state to ensure UI is consistent
      emit(FeedbackOptionsLoadedState(
        options: _feedbackOptions,
        selectedOptionIds: _selectedFeedbackOptionIds,
      ));
    } catch (e) {
      print('Error loading student feedback: $e');
      emit(
          TeacherCommentError('Öğrenci görüşleri yüklenirken hata oluştu: $e'));

      // Even in case of error, we should maintain the empty feedback list
      // state we already emitted above
    }
  }

  Future<void> _onAddFeedback(
      AddFeedbackEvent event, Emitter<TeacherCommentState> emit) async {
    emit(TeacherCommentLoading());
    try {
      await repository.addFeedback(event.studentId, event.feedbackOptionIds);

      // Clear selected options
      _selectedFeedbackOptionIds = {};

      // Show success message
      emit(TeacherCommentOperationSuccess('Görüş başarıyla eklendi'));

      // Reload student feedback
      add(LoadStudentFeedbackEvent(event.studentId));

      // Update options state with cleared selection
      emit(FeedbackOptionsLoadedState(
        options: _feedbackOptions,
        selectedOptionIds: _selectedFeedbackOptionIds,
      ));
    } catch (e) {
      emit(TeacherCommentError('Failed to add feedback: $e'));
    }
  }

  Future<void> _onDeleteFeedback(
      DeleteFeedbackEvent event, Emitter<TeacherCommentState> emit) async {
    emit(TeacherCommentLoading());
    try {
      await repository.deleteFeedback(event.feedbackId);

      emit(TeacherCommentOperationSuccess('Görüş başarıyla silindi'));

      // Reload student feedback if a student is selected
      if (_selectedStudent != null) {
        add(LoadStudentFeedbackEvent(_selectedStudent!.id));
      }
    } catch (e) {
      emit(TeacherCommentError('Failed to delete feedback: $e'));
    }
  }

  void _onUpdateSelectedStudents(
      UpdateSelectedStudentsEvent event, Emitter<TeacherCommentState> emit) {
    _selectedStudents = event.selectedStudents;

    emit(StudentsLoadedState(
      students: _students,
      selectedClass: _selectedClass!,
      selectedStudent: _selectedStudent,
      selectedStudents: _selectedStudents,
      isMultiSelectMode: _isMultiSelectMode,
    ));
  }

  void _onUpdateSelectedFeedbackOptions(
      UpdateSelectedFeedbackOptionsEvent event,
      Emitter<TeacherCommentState> emit) {
    _selectedFeedbackOptionIds = event.selectedOptionIds;

    emit(FeedbackOptionsLoadedState(
      options: _feedbackOptions,
      selectedOptionIds: _selectedFeedbackOptionIds,
    ));
  }

  Future<void> _onAddBulkFeedback(
      AddBulkFeedbackEvent event, Emitter<TeacherCommentState> emit) async {
    // Start the operation with loading state
    emit(BulkFeedbackOperationState(
      isInProgress: true,
      totalCount: event.students.length * event.feedbackOptionIds.length,
    ));

    try {
      final result = await repository.addBulkFeedback(
          event.students, event.feedbackOptionIds);

      // Operation completed
      emit(BulkFeedbackOperationState(
        isInProgress: false,
        successCount: result['count'],
        totalCount: event.students.length * event.feedbackOptionIds.length,
      ));

      // Show success message
      emit(TeacherCommentOperationSuccess(
          '${event.students.length} öğrenci için ${event.feedbackOptionIds.length} görüş başarıyla eklendi'));

      // Clear selections
      _selectedStudents = {};
      _selectedFeedbackOptionIds = {};

      // Update state to reflect cleared selections
      emit(StudentsLoadedState(
        students: _students,
        selectedClass: _selectedClass!,
        selectedStudent: _selectedStudent,
        selectedStudents: _selectedStudents,
        isMultiSelectMode: _isMultiSelectMode,
      ));

      emit(FeedbackOptionsLoadedState(
        options: _feedbackOptions,
        selectedOptionIds: _selectedFeedbackOptionIds,
      ));
    } catch (e) {
      // Operation failed
      emit(TeacherCommentError('Failed to add bulk feedback: $e'));

      // Update state to show operation is no longer in progress
      emit(BulkFeedbackOperationState(
        isInProgress: false,
        failureCount: event.students.length * event.feedbackOptionIds.length,
        totalCount: event.students.length * event.feedbackOptionIds.length,
      ));
    }
  }

  void _onToggleMultiSelectMode(
      ToggleMultiSelectModeEvent event, Emitter<TeacherCommentState> emit) {
    _isMultiSelectMode = event.isMultiSelectMode;

    // If turning off multi-select mode, clear selected students
    if (!_isMultiSelectMode) {
      _selectedStudents = {};
    }

    emit(StudentsLoadedState(
      students: _students,
      selectedClass: _selectedClass!,
      selectedStudent: _selectedStudent,
      selectedStudents: _selectedStudents,
      isMultiSelectMode: _isMultiSelectMode,
    ));
  }
}
