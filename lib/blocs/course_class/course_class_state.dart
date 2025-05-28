import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/course_classes_model.dart';

abstract class CourseClassState extends Equatable {
  final List<CourseClass> courseClasses;
  final CourseClass? selectedCourseClass;

  const CourseClassState({
    this.courseClasses = const <CourseClass>[],
    this.selectedCourseClass,
  });

  @override
  List<Object?> get props => [courseClasses, selectedCourseClass];
}

// Başlangıç durumu
class CourseClassInitial extends CourseClassState {
  const CourseClassInitial() : super();
}

// Yükleme durumu
class CourseClassLoading extends CourseClassState {
  const CourseClassLoading({
    List<CourseClass> courseClasses = const <CourseClass>[],
    CourseClass? selectedCourseClass,
  }) : super(
          courseClasses: courseClasses,
          selectedCourseClass: selectedCourseClass,
        );
}

// Ders-sınıf atamaları yüklendi durumu
class CourseClassesLoaded extends CourseClassState {
  const CourseClassesLoaded(
    List<CourseClass> courseClasses, {
    CourseClass? selectedCourseClass,
  }) : super(
          courseClasses: courseClasses,
          selectedCourseClass: selectedCourseClass,
        );
}

// Ders-sınıf ataması seçildi durumu
class CourseClassSelected extends CourseClassState {
  const CourseClassSelected(
    CourseClass courseClass, {
    List<CourseClass> courseClasses = const <CourseClass>[],
  }) : super(
          courseClasses: courseClasses,
          selectedCourseClass: courseClass,
        );
}

// Hata durumu
class CourseClassError extends CourseClassState {
  final String message;

  const CourseClassError(
    this.message, {
    List<CourseClass> courseClasses = const <CourseClass>[],
    CourseClass? selectedCourseClass,
  }) : super(
          courseClasses: courseClasses,
          selectedCourseClass: selectedCourseClass,
        );

  @override
  List<Object?> get props => [message, courseClasses, selectedCourseClass];
}

// İşlem başarılı durumu
class CourseClassOperationSuccess extends CourseClassState {
  final String message;

  const CourseClassOperationSuccess(
    this.message, {
    List<CourseClass> courseClasses = const <CourseClass>[],
    CourseClass? selectedCourseClass,
  }) : super(
          courseClasses: courseClasses,
          selectedCourseClass: selectedCourseClass,
        );

  @override
  List<Object?> get props => [message, courseClasses, selectedCourseClass];
} 