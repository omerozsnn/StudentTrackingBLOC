import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';

abstract class CourseState extends Equatable {
  final List<Course> courses;
  final Course? selectedCourse;

  const CourseState({
    this.courses = const <Course>[],
    this.selectedCourse,
  });

  @override
  List<Object?> get props => [courses, selectedCourse];
}

// Başlangıç durumu
class CourseInitial extends CourseState {
  const CourseInitial() : super();
}

// Yükleme durumu
class CourseLoading extends CourseState {
  const CourseLoading({
    List<Course> courses = const <Course>[],
    Course? selectedCourse,
  }) : super(
          courses: courses,
          selectedCourse: selectedCourse,
        );
}

// Dersler yüklendi durumu
class CoursesLoaded extends CourseState {
  const CoursesLoaded(
    List<Course> courses, {
    Course? selectedCourse,
  }) : super(
          courses: courses,
          selectedCourse: selectedCourse,
        );
}

// Ders seçildi durumu
class CourseSelected extends CourseState {
  const CourseSelected(
    Course course, {
    List<Course> courses = const <Course>[],
  }) : super(
          courses: courses,
          selectedCourse: course,
        );
}

// Hata durumu
class CourseError extends CourseState {
  final String message;

  const CourseError(
    this.message, {
    List<Course> courses = const <Course>[],
    Course? selectedCourse,
  }) : super(
          courses: courses,
          selectedCourse: selectedCourse,
        );

  @override
  List<Object?> get props => [message, courses, selectedCourse];
}

// İşlem başarılı durumu
class CourseOperationSuccess extends CourseState {
  final String message;

  const CourseOperationSuccess(
    this.message, {
    List<Course> courses = const <Course>[],
    Course? selectedCourse,
  }) : super(
          courses: courses,
          selectedCourse: selectedCourse,
        );

  @override
  List<Object?> get props => [message, courses, selectedCourse];
}

// Bilgi mesajı durumu
class CourseOperationMessage extends CourseState {
  final String message;

  const CourseOperationMessage(
    this.message, {
    List<Course> courses = const <Course>[],
    Course? selectedCourse,
  }) : super(
          courses: courses,
          selectedCourse: selectedCourse,
        );

  @override
  List<Object?> get props => [message, courses, selectedCourse];
} 