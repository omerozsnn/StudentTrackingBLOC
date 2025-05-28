import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_repository.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'package:flutter/foundation.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository repository;
  List<Course> courses = [];
  Course? selectedCourse;

  CourseBloc({required this.repository}) : super(CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<LoadCoursesWithPagination>(_onLoadCoursesWithPagination);
    on<LoadCoursesForDropdown>(_onLoadCoursesForDropdown);
    on<SearchCourses>(_onSearchCourses);
    on<SelectCourse>(_onSelectCourse);
    on<AddCourse>(_onAddCourse);
    on<UpdateCourse>(_onUpdateCourse);
    on<DeleteCourse>(_onDeleteCourse);
    on<UploadCourseExcel>(_onUploadCourseExcel);
    on<CourseLoadingEvent>(_onCourseLoading);
  }

  Future<void> _onLoadCourses(
      LoadCourses event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      debugPrint("Loading courses...");
      final loadedCourses = await repository.getCourses();
      debugPrint("Courses loaded: ${loadedCourses.length}");
      courses = loadedCourses;
      emit(CoursesLoaded(courses));
    } catch (e) {
      debugPrint("Error loading courses: $e");
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onLoadCoursesWithPagination(
      LoadCoursesWithPagination event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final loadedCourses = await repository.getCoursesWithPagination(
          event.page, event.limit);
      courses = loadedCourses;
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onLoadCoursesForDropdown(
      LoadCoursesForDropdown event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final loadedCourses = await repository.getCoursesForDropdown();
      courses = loadedCourses;
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onSearchCourses(
      SearchCourses event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      courses = await repository.searchCourses(event.query);
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onSelectCourse(
      SelectCourse event, Emitter<CourseState> emit) async {
    if (event.course == null) {
      selectedCourse = null;
      emit(CoursesLoaded(courses));
      return;
    }

    emit(CourseLoading());
    try {
      final course = await repository.getCourseById(event.course!.id);
      selectedCourse = course;
      emit(CourseSelected(course, courses: courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onAddCourse(
      AddCourse event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final newCourse = await repository.addCourse(event.course);
      courses.add(newCourse);
      emit(CourseOperationSuccess('Ders başarıyla eklendi.', courses: courses));
      emit(CoursesLoaded(courses));
    } catch (e) {
      debugPrint("Ders ekleme hatası: ${e.toString()}");
      emit(CourseError("Ders eklenemedi: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateCourse(
      UpdateCourse event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final updatedCourse = await repository.updateCourse(event.course);
      final index = courses.indexWhere((c) => c.id == updatedCourse.id);
      if (index != -1) {
        courses[index] = updatedCourse;
      }
      
      if (selectedCourse?.id == updatedCourse.id) {
        selectedCourse = updatedCourse;
      }
      
      emit(CourseOperationSuccess('Ders başarıyla güncellendi.', 
        courses: courses,
        selectedCourse: selectedCourse
      ));
      emit(CoursesLoaded(courses, selectedCourse: selectedCourse));
    } catch (e) {
      debugPrint("Ders güncelleme hatası: ${e.toString()}");
      emit(CourseError("Ders güncellenemedi: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteCourse(
      DeleteCourse event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final success = await repository.deleteCourse(event.courseId);
      if (success) {
        courses.removeWhere((course) => course.id == event.courseId);
        
        if (selectedCourse?.id == event.courseId) {
          selectedCourse = null;
        }
        
        emit(CourseOperationSuccess('Ders başarıyla silindi.'));
        emit(CoursesLoaded(courses));
      } else {
        emit(CourseError('Ders silinemedi.'));
      }
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onUploadCourseExcel(
      UploadCourseExcel event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final success = await repository.importCoursesFromExcel(event.file);
      if (success) {
        // Refresh the course list after Excel import
        final loadedCourses = await repository.getCourses();
        courses = loadedCourses;
        
        emit(CourseOperationSuccess('Dersler Excel\'den başarıyla içe aktarıldı.'));
        emit(CoursesLoaded(courses));
      } else {
        emit(CourseError('Dersler Excel\'den içe aktarılamadı.'));
      }
    } catch (e) {
      debugPrint("Excel'den ders içe aktarma hatası: ${e.toString()}");
      emit(CourseError("Excel'den ders içe aktarılamadı: ${e.toString()}"));
    }
  }

  void _onCourseLoading(CourseLoadingEvent event, Emitter<CourseState> emit) {
    emit(CourseLoading());
  }
} 