import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_repository.dart';
import 'package:ogrenci_takip_sistemi/models/course_classes_model.dart';
import 'package:flutter/foundation.dart';

class CourseClassBloc extends Bloc<CourseClassEvent, CourseClassState> {
  final CourseClassRepository repository;
  List<CourseClass> courseClasses = [];
  CourseClass? selectedCourseClass;

  CourseClassBloc({required this.repository}) : super(CourseClassInitial()) {
    on<LoadCourseClasses>(_onLoadCourseClasses);
    on<LoadCourseClassesByClassId>(_onLoadCourseClassesByClassId);
    on<SelectCourseClass>(_onSelectCourseClass);
    on<AddCourseClass>(_onAddCourseClass);
    on<UpdateCourseClass>(_onUpdateCourseClass);
    on<DeleteCourseClass>(_onDeleteCourseClass);
    on<CourseClassLoadingEvent>(_onCourseClassLoading);
  }

  Future<void> _onLoadCourseClasses(
      LoadCourseClasses event, Emitter<CourseClassState> emit) async {
    emit(CourseClassLoading());
    try {
      final loadedCourseClasses = await repository.getCourseClasses();
      courseClasses = loadedCourseClasses;
      emit(CourseClassesLoaded(courseClasses));
    } catch (e) {
      emit(CourseClassError(e.toString()));
    }
  }

  Future<void> _onLoadCourseClassesByClassId(
      LoadCourseClassesByClassId event, Emitter<CourseClassState> emit) async {
    emit(CourseClassLoading());
    try {
      final loadedCourseClasses = await repository.getCourseClassesByClassId(event.classId);
      courseClasses = loadedCourseClasses;
      emit(CourseClassesLoaded(courseClasses));
    } catch (e) {
      emit(CourseClassError(e.toString()));
    }
  }

  Future<void> _onSelectCourseClass(
      SelectCourseClass event, Emitter<CourseClassState> emit) async {
    if (event.courseClass == null) {
      selectedCourseClass = null;
      emit(CourseClassesLoaded(courseClasses));
      return;
    }

    emit(CourseClassLoading());
    try {
      final courseClass = await repository.getCourseClassById(event.courseClass!.id);
      selectedCourseClass = courseClass;
      emit(CourseClassSelected(courseClass, courseClasses: courseClasses));
    } catch (e) {
      emit(CourseClassError(e.toString()));
    }
  }

  Future<void> _onAddCourseClass(
      AddCourseClass event, Emitter<CourseClassState> emit) async {
    emit(CourseClassLoading());
    try {
      final newCourseClass = await repository.addCourseClass(event.courseClass);
      courseClasses.add(newCourseClass);
      emit(CourseClassOperationSuccess('Ders sınıfa başarıyla atandı.', courseClasses: courseClasses));
      emit(CourseClassesLoaded(courseClasses));
    } catch (e) {
      debugPrint("Ders-sınıf ataması ekleme hatası: ${e.toString()}");
      emit(CourseClassError("Ders-sınıf ataması eklenemedi: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateCourseClass(
      UpdateCourseClass event, Emitter<CourseClassState> emit) async {
    emit(CourseClassLoading());
    try {
      final updatedCourseClass = await repository.updateCourseClass(event.courseClass);
      final index = courseClasses.indexWhere((c) => c.id == updatedCourseClass.id);
      if (index != -1) {
        courseClasses[index] = updatedCourseClass;
      }
      
      if (selectedCourseClass?.id == updatedCourseClass.id) {
        selectedCourseClass = updatedCourseClass;
      }
      
      emit(CourseClassOperationSuccess('Ders-sınıf ataması başarıyla güncellendi.', 
        courseClasses: courseClasses,
        selectedCourseClass: selectedCourseClass
      ));
      emit(CourseClassesLoaded(courseClasses, selectedCourseClass: selectedCourseClass));
    } catch (e) {
      debugPrint("Ders-sınıf ataması güncelleme hatası: ${e.toString()}");
      emit(CourseClassError("Ders-sınıf ataması güncellenemedi: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteCourseClass(
      DeleteCourseClass event, Emitter<CourseClassState> emit) async {
    emit(CourseClassLoading());
    try {
      final success = await repository.deleteCourseClass(event.courseClassId);
      if (success) {
        courseClasses.removeWhere((courseClass) => courseClass.id == event.courseClassId);
        
        if (selectedCourseClass?.id == event.courseClassId) {
          selectedCourseClass = null;
        }
        
        emit(CourseClassOperationSuccess('Ders-sınıf ataması başarıyla silindi.'));
        emit(CourseClassesLoaded(courseClasses));
      } else {
        emit(CourseClassError('Ders-sınıf ataması silinemedi.'));
      }
    } catch (e) {
      emit(CourseClassError(e.toString()));
    }
  }

  void _onCourseClassLoading(CourseClassLoadingEvent event, Emitter<CourseClassState> emit) {
    emit(CourseClassLoading());
  }
} 