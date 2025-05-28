import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/api.dart/grades_api.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_state.dart';
import 'package:ogrenci_takip_sistemi/models/grades_model.dart';
import 'package:ogrenci_takip_sistemi/models/course_classes_model.dart';
import 'package:ogrenci_takip_sistemi/utils/excel_helper.dart';
import 'package:ogrenci_takip_sistemi/utils/snackbar_helper.dart';
import 'package:ogrenci_takip_sistemi/widgets/grades/class_course_selector.dart';
import 'package:ogrenci_takip_sistemi/widgets/grades/grade_input_dialog.dart';
import 'package:ogrenci_takip_sistemi/widgets/grades/grades_table.dart';

class GradeTrackingScreen extends StatefulWidget {
  const GradeTrackingScreen({Key? key}) : super(key: key);

  @override
  _GradeTrackingScreenState createState() => _GradeTrackingScreenState();
}

class _GradeTrackingScreenState extends State<GradeTrackingScreen> {
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    // Load classes when the screen initializes
    context.read<ClassBloc>().add(LoadClasses());
    // Load all course-class assignments
    context.read<CourseClassBloc>().add(LoadCourseClasses());
  }

  @override
  void dispose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Not Ekranı'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 2,
      actions: [
        BlocBuilder<GradesBloc, GradesState>(
          builder: (context, state) {
            final gradesBloc = context.read<GradesBloc>();
            final selectedSemester = gradesBloc.selectedSemester;

            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _uploadExcel(context),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.upload_file,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '$selectedSemester. Dönem Excel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildDropdowns(),
        _buildGradesTable(),
      ],
    );
  }

  Widget _buildDropdowns() {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, classState) {
        if (classState is ClassLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (classState is ClassError) {
          return Center(child: Text('Hata: ${classState.message}'));
        }

        final classBloc = context.read<ClassBloc>();
        final classes = classBloc.classes;
        final selectedClass = classBloc.selectedClass?.sinifAdi;

        // Get course class bloc to access courses
        final courseClassBloc = context.read<CourseClassBloc>();
        print('CourseClasses count: ${courseClassBloc.courseClasses.length}');

        // Extract courses and remove duplicates by ders_id
        final Map<int, Map<String, dynamic>> uniqueCourses = {};

        for (final courseClass in courseClassBloc.courseClasses) {
          // Only process courses for the selected class
          if (classBloc.selectedClass != null &&
              courseClass.sinifId == classBloc.selectedClass!.id) {
            print(
                'CourseClass: id=${courseClass.id}, sinifId=${courseClass.sinifId}, dersId=${courseClass.dersId}, course=${courseClass.course?.dersAdi}');

            // Only add if not already in the map
            if (!uniqueCourses.containsKey(courseClass.dersId) &&
                courseClass.course != null) {
              uniqueCourses[courseClass.dersId] = {
                'ders_id': courseClass.dersId,
                'ders_adi': courseClass.course?.dersAdi ?? 'Bilinmeyen Ders',
              };
            }
          }
        }

        final courses = uniqueCourses.values.toList();
        print('Unique courses: $courses');

        // Determine selected course name
        String? selectedCourse;
        if (courseClassBloc.selectedCourseClass != null &&
            courseClassBloc.selectedCourseClass!.course != null) {
          selectedCourse = courseClassBloc.selectedCourseClass!.course!.dersAdi;
          print('Selected course: $selectedCourse');
        } else {
          print('No selected course found');
        }

        // Use BlocBuilder for GradesBloc to listen for semester changes
        return BlocBuilder<GradesBloc, GradesState>(
          builder: (context, gradesState) {
            final gradesBloc = context.read<GradesBloc>();
            final selectedSemester = gradesBloc.selectedSemester;
            print('Building dropdown with semester: $selectedSemester');

            return ClassCourseSelector(
              key: ValueKey('class-course-selector-$selectedSemester'),
              classes: classes,
              selectedClass: selectedClass,
              courses: courses,
              selectedCourse: selectedCourse,
              selectedSemester: selectedSemester,
              onClassChanged: (className) {
                print('Class selected: $className');
                _onClassSelected(context, className);
              },
              onCourseChanged: (courseName) {
                print('Course selected: $courseName');
                _onCourseSelected(context, courses, courseName);
              },
              onSemesterChanged: (semester) {
                print('Semester selected: $semester');
                _onSemesterSelected(context, semester);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGradesTable() {
    return BlocConsumer<GradesBloc, GradesState>(
      listener: (context, state) {
        if (state is GradesError) {
          SnackbarHelper.showErrorSnackBar(context, state.message);
        } else if (state is GradeOperationSuccess) {
          SnackbarHelper.showSuccessSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is GradesLoading) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final studentBloc = context.read<StudentBloc>();
        final List<Map<String, dynamic>> studentData;

        if (state is GradesLoaded) {
          // Convert Grade objects to student maps
          studentData = _convertGradesToStudentMaps(state.grades);
        } else {
          studentData = [];
        }

        // Create an empty table when course is selected but there's no data
        final classBloc = context.read<ClassBloc>();
        final courseClassBloc = context.read<CourseClassBloc>();
        final gradesBloc = context.read<GradesBloc>();

        final bool shouldShowEmptyTable = classBloc.selectedClass != null &&
            courseClassBloc.selectedCourseClass != null;

        if (shouldShowEmptyTable) {
          // Show an empty table with existing students
          if (studentData.isEmpty && studentBloc.students.isNotEmpty) {
            // Create placeholder data for the table
            final placeholderData = studentBloc.students
                .map((student) => {
                      'id': student.id,
                      'ogrenci_no': student.ogrenciNo,
                      'ad_soyad': student.adSoyad,
                      'grades': {},
                    })
                .toList();

            return Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Bu sınıf ve ders için not verisi bulunamadı.\nExcel yükleyebilir veya not girebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GradesTable(
                      students: placeholderData,
                      onGradeTap: (student, gradeType) {
                        _showGradeDialog(context, student, gradeType);
                      },
                      horizontalScrollController: horizontalScrollController,
                      verticalScrollController: verticalScrollController,
                    ),
                  ),
                ],
              ),
            );
          }

          if (studentData.isNotEmpty) {
            return Expanded(
              child: GradesTable(
                students: studentData,
                onGradeTap: (student, gradeType) {
                  _showGradeDialog(context, student, gradeType);
                },
                horizontalScrollController: horizontalScrollController,
                verticalScrollController: verticalScrollController,
              ),
            );
          }
        }

        return const Expanded(
          child: Center(
            child: Text('Lütfen sınıf ve ders seçin'),
          ),
        );
      },
    );
  }

  void _onClassSelected(BuildContext context, String className) {
    print('Processing class selection: $className');

    // Update class selection in class bloc
    final classBloc = context.read<ClassBloc>();
    final selectedClass = classBloc.classes.firstWhere(
      (cls) => cls.sinifAdi == className,
      orElse: () => classBloc.classes.first,
    );

    print('Found class: ${selectedClass.sinifAdi} with ID ${selectedClass.id}');
    classBloc.add(SelectClass(selectedClass));

    // Load students for this class
    final studentBloc = context.read<StudentBloc>();
    studentBloc.add(LoadStudentsByClass(className));

    // Load courses for this class
    final courseClassBloc = context.read<CourseClassBloc>();
    courseClassBloc.add(LoadCourseClassesByClassId(selectedClass.id));

    // Reset grades when class changes
    final gradesBloc = context.read<GradesBloc>();
    gradesBloc.add(const SetSelectedCourseClass(courseClassId: null));
  }

  void _onCourseSelected(BuildContext context,
      List<Map<String, dynamic>> courses, String courseName) {
    print('Processing course selection: $courseName');

    // Find the course ID
    Map<String, dynamic>? courseData;
    try {
      courseData = courses.firstWhere(
        (course) => course['ders_adi'] == courseName,
      );
      print(
          'Found course: ${courseData['ders_adi']} with ID ${courseData['ders_id']}');
    } catch (e) {
      // If no matching course is found, use the first one if available
      if (courses.isNotEmpty) {
        courseData = courses.first;
        print('Using first available course: ${courseData['ders_adi']}');
      } else {
        // No courses available
        print('No courses available to select');
        return;
      }
    }

    final classBloc = context.read<ClassBloc>();
    if (classBloc.selectedClass == null) {
      print('No class selected, cannot select course');
      return;
    }

    final classId = classBloc.selectedClass!.id;
    final courseId = courseData['ders_id'];
    print(
        'Looking for course class with classId=$classId and courseId=$courseId');

    // Make sure courseClasses is not empty before trying to find a match
    final courseClassBloc = context.read<CourseClassBloc>();
    if (courseClassBloc.courseClasses.isEmpty) {
      print('No course classes available');
      return;
    }

    // Get the CourseClassId
    CourseClass? courseClass;
    try {
      courseClass = courseClassBloc.courseClasses.firstWhere(
        (cc) => cc.sinifId == classId && cc.dersId == courseId,
      );
      print('Found matching course class: ID=${courseClass.id}');
    } catch (e) {
      // If no matching course class is found, use the first one
      if (courseClassBloc.courseClasses.isNotEmpty) {
        courseClass = courseClassBloc.courseClasses.first;
        print('Using first available course class: ID=${courseClass.id}');
      } else {
        print('No course classes to select from');
        return;
      }
    }

    // Update the selected course class in the CourseClassBloc
    courseClassBloc.add(SelectCourseClass(courseClass));

    // Update grades for this course class
    final gradesBloc = context.read<GradesBloc>();
    gradesBloc.add(SetSelectedCourseClass(courseClassId: courseClass.id));

    // Also load grades for this course class
    gradesBloc.add(LoadGradesByCourseClass(
      courseClassId: courseClass.id,
      semester: gradesBloc.selectedSemester,
    ));
  }

  void _onSemesterSelected(BuildContext context, int semester) {
    print('Processing semester change to: $semester');

    final gradesBloc = context.read<GradesBloc>();

    // First just update the semester value in the bloc
    gradesBloc.add(SetSelectedSemester(semester: semester));

    // If we have a course class selected, reload grades with new semester
    if (gradesBloc.selectedCourseClassId != null) {
      print(
          'Loading grades for course class ID: ${gradesBloc.selectedCourseClassId}, semester: $semester');
      gradesBloc.add(LoadGradesByCourseClass(
        courseClassId: gradesBloc.selectedCourseClassId,
        semester: semester,
      ));
    } else {
      print('No course class selected, not loading grades');
    }
  }

  List<Map<String, dynamic>> _convertGradesToStudentMaps(List<Grade> grades) {
    final Map<int, Map<String, dynamic>> studentMap = {};

    // Get all students
    final studentBloc = context.read<StudentBloc>();
    final students = studentBloc.students;

    // Create map for each student
    for (final student in students) {
      studentMap[student.id] = {
        'id': student.id,
        'ogrenci_no': student.ogrenciNo,
        'ad_soyad': student.adSoyad,
        'grades': {},
      };
    }

    // Add grades to corresponding students
    for (final grade in grades) {
      if (studentMap.containsKey(grade.ogrenciId)) {
        studentMap[grade.ogrenciId]!['grades'] = grade.toJson();
      }
    }

    return studentMap.values.toList();
  }

  void _showGradeDialog(
      BuildContext context, Map<String, dynamic> student, String gradeType) {
    // Get the current value if it exists
    final grades = student['grades'] ?? {};
    final initialValue = grades is Map &&
            grades.containsKey(gradeType) &&
            grades[gradeType] != null
        ? grades[gradeType].toString()
        : '';

    showDialog(
      context: context,
      builder: (context) {
        return GradeInputDialog(
          studentName: student['ad_soyad'],
          gradeType: gradeType,
          initialValue: initialValue,
          onSave: (value) {
            _saveGrade(context, student, gradeType, value);
          },
        );
      },
    );
  }

  void _saveGrade(BuildContext context, Map<String, dynamic> student,
      String gradeType, String gradeValue) {
    final gradesBloc = context.read<GradesBloc>();
    final courseClassId = gradesBloc.selectedCourseClassId;
    final semester = gradesBloc.selectedSemester;

    if (courseClassId == null) {
      SnackbarHelper.showErrorSnackBar(
          context, 'Önce sınıf ve ders seçmelisiniz.');
      return;
    }

    // Parse the grade value
    double? parsedValue =
        gradeValue.isNotEmpty ? double.tryParse(gradeValue) : null;

    // Create or update the grade
    final grades = student['grades'] ?? {};
    final hasExistingGrade =
        grades is Map && grades.containsKey('id') && grades['id'] != null;

    if (hasExistingGrade) {
      // Update existing grade
      final gradeMap = Map<String, dynamic>.from(grades);
      gradeMap[gradeType] = parsedValue;

      final grade = Grade.fromJson(gradeMap);
      gradesBloc.add(UpdateGrade(gradeId: grade.id!, grade: grade));
    } else {
      // Create new grade
      final gradeMap = {
        'ogrenci_id': student['id'],
        'sinif_dersleri_id': courseClassId,
        'donem': semester,
        gradeType: parsedValue,
      };

      final grade = Grade.fromJson(gradeMap);
      gradesBloc.add(CreateGrade(grade: grade));
    }
  }

  void _uploadExcel(BuildContext context) {
    final gradesBloc = context.read<GradesBloc>();

    if (gradesBloc.selectedCourseClassId == null) {
      SnackbarHelper.showErrorSnackBar(
          context, 'Lütfen önce sınıf ve ders seçin');
      return;
    }

    ExcelHelper.showExcelUploadDialog(
      context: context,
      title: '${gradesBloc.selectedSemester}. Dönem Not Yükleme',
      message: 'Excel dosyasını yüklemek istediğinizden emin misiniz?',
      onUpload: (file) {
        SnackbarHelper.showLoadingSnackBar(context,
            'Excel verisi yükleniyor... Dönem: ${gradesBloc.selectedSemester}');

        gradesBloc.add(UploadExcelGrades(excelFile: file));
      },
    );
  }
}
