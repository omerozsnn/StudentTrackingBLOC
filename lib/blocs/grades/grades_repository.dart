import 'dart:io';
import 'package:ogrenci_takip_sistemi/api.dart/grades_api.dart' as api;
import 'package:ogrenci_takip_sistemi/models/grades_model.dart';

class GradesRepository {
  final api.GradesRepository apiService;

  GradesRepository({required this.apiService});

  // Create a new grade
  Future<Grade> createGrade(Grade grade) async {
    return await apiService.createGrade(grade);
  }

  // Get a grade by ID
  Future<Grade> getGrade(int id) async {
    return await apiService.getGrade(id);
  }

  // Update a grade
  Future<Grade> updateGrade(int id, Grade grade) async {
    return await apiService.updateGrade(id, grade);
  }

  // Delete a grade
  Future<void> deleteGrade(int id) async {
    return await apiService.deleteGrade(id);
  }

  // Get all grades for a student
  Future<List<Grade>> getStudentGrades(int studentId) async {
    return await apiService.getStudentGrades(studentId);
  }

  // Get all grades for a course class
  Future<List<Grade>> getCourseClassGrades(int courseClassId) async {
    return await apiService.getCourseClassGrades(courseClassId);
  }

  // Get grades for a specific semester and course class
  Future<List<Grade>> getGradesBySemester(
      int courseClassId, int semester) async {
    return await apiService.getGradesBySemester(courseClassId, semester);
  }

  // Get student semester grades
  Future<StudentSemesterGrades> getStudentSemesterGrades(
      int studentId, int semester) async {
    return await apiService.getStudentSemesterGrades(studentId, semester);
  }

  // Upload Excel grades file
  Future<void> uploadExcelGrades(
      File file, int courseClassId, int semester) async {
    return await apiService.uploadExcelGrades(file, courseClassId, semester);
  }

  // Get class grades by class ID and semester
  Future<ClassGradesByCourse> getClassGradesByClassId(
      int classId, int semester) async {
    return await apiService.getClassGradesByClassId(classId, semester);
  }

  // Get course class grades with rankings
  Future<CourseClassGrades> getClassGradesByCourseClassId(
      int courseClassId, int semester) async {
    return await apiService.getClassGradesByCourseClassId(
        courseClassId, semester);
  }
}
