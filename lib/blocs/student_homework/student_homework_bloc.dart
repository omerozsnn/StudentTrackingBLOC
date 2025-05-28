import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/student_homework_model.dart';
import 'student_homework_event.dart';
import 'student_homework_state.dart';
import 'student_homework_repository.dart';

class StudentHomeworkBloc
    extends Bloc<StudentHomeworkEvent, StudentHomeworkState> {
  final StudentHomeworkRepository _repository;

  StudentHomeworkBloc({required StudentHomeworkRepository repository})
      : _repository = repository,
        super(const StudentHomeworkState()) {
    on<LoadAllStudentHomeworks>(_onLoadAllStudentHomeworks);
    on<LoadStudentHomeworksByStudentId>(_onLoadStudentHomeworksByStudentId);
    on<LoadStudentHomeworkById>(_onLoadStudentHomeworkById);
    on<AddStudentHomework>(_onAddStudentHomework);
    on<AddBulkStudentHomeworks>(_onAddBulkStudentHomeworks);
    on<UpdateStudentHomework>(_onUpdateStudentHomework);
    on<DeleteStudentHomework>(_onDeleteStudentHomework);
    on<LoadStudentsByClassAndHomework>(_onLoadStudentsByClassAndHomework);
    on<BulkUpdateStudentHomeworks>(_onBulkUpdateStudentHomeworks);
    on<BulkGetStudentHomeworks>(_onBulkGetStudentHomeworks);
    on<ClearStudentHomeworkSelection>(_onClearStudentHomeworkSelection);
  }

  Future<void> _onLoadAllStudentHomeworks(
      LoadAllStudentHomeworks event, Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      final studentHomeworks = await _repository.getAllStudentHomeworks();
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        studentHomeworks: studentHomeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadStudentHomeworksByStudentId(
      LoadStudentHomeworksByStudentId event,
      Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      final studentHomeworks =
          await _repository.getStudentHomeworksByStudentId(event.studentId);
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        studentHomeworks: studentHomeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadStudentHomeworkById(
      LoadStudentHomeworkById event, Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      final studentHomework =
          await _repository.getStudentHomeworkById(event.id);
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        selectedStudentHomework: studentHomework,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddStudentHomework(
      AddStudentHomework event, Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      await _repository.addStudentHomework(event.studentHomework);
      final studentHomeworks = await _repository.getAllStudentHomeworks();
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        studentHomeworks: studentHomeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddBulkStudentHomeworks(
      AddBulkStudentHomeworks event, Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      for (final studentHomework in event.studentHomeworks) {
        await _repository.addStudentHomework(studentHomework);
      }

      final studentHomeworks = await _repository.getAllStudentHomeworks();
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        studentHomeworks: studentHomeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateStudentHomework(
      UpdateStudentHomework event, Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      await _repository.updateStudentHomework(event.studentHomework);
      final studentHomeworks = await _repository.getAllStudentHomeworks();
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        studentHomeworks: studentHomeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteStudentHomework(
      DeleteStudentHomework event, Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      await _repository.deleteStudentHomework(event.id);
      final studentHomeworks = await _repository.getAllStudentHomeworks();
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        studentHomeworks: studentHomeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadStudentsByClassAndHomework(
      LoadStudentsByClassAndHomework event,
      Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      final students = await _repository.getStudentsByClassAndHomework(
          event.classId, event.homeworkId);
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        studentsForHomework: students,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onBulkUpdateStudentHomeworks(BulkUpdateStudentHomeworks event,
      Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      await _repository.bulkUpdateStudentHomework(event.updates);
      final studentHomeworks = await _repository.getAllStudentHomeworks();
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        studentHomeworks: studentHomeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onBulkGetStudentHomeworks(
      BulkGetStudentHomeworks event, Emitter<StudentHomeworkState> emit) async {
    emit(state.copyWith(status: StudentHomeworkStatus.loading));
    try {
      final studentHomeworks =
          await _repository.bulkGetStudentHomework(event.studentIds);
      emit(state.copyWith(
        status: StudentHomeworkStatus.loaded,
        studentHomeworks: studentHomeworks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentHomeworkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearStudentHomeworkSelection(
      ClearStudentHomeworkSelection event, Emitter<StudentHomeworkState> emit) {
    emit(state.copyWith(
      clearSelectedStudentHomework: true,
    ));
  }
}
