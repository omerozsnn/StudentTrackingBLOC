import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_state.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/course_classes_model.dart';

class ClassCourseSelectorWidget extends StatefulWidget {
  final Function(String, int?) onClassSelected;
  final Function(String, int, int) onCourseSelected;

  const ClassCourseSelectorWidget({
    Key? key,
    required this.onClassSelected,
    required this.onCourseSelected,
  }) : super(key: key);

  @override
  State<ClassCourseSelectorWidget> createState() =>
      _ClassCourseSelectorWidgetState();
}

class _ClassCourseSelectorWidgetState extends State<ClassCourseSelectorWidget> {
  String? selectedClass;
  int? selectedClassId;
  String? selectedCourse;
  int? selectedCourseId;
  int? courseClassId;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  void _loadClasses() {
    context.read<ClassBloc>().add(LoadClassesForDropdown());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Class Selector Card
        _buildClassSelector(),
        const SizedBox(height: 16),
        // Course Selector Card
        _buildCourseSelector(),
      ],
    );
  }

  Widget _buildClassSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.blueGrey.shade400, size: 18),
                SizedBox(width: 8),
                Text(
                  'Sınıf Seçimi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<ClassBloc, ClassState>(
              builder: (context, state) {
                final classes = state.classes;

                // Debug: Sınıf adlarını kontrol et
                for (var classItem in classes) {
                  print('Dropdown sınıf adı: ${classItem.sinifAdi}');
                }

                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blueGrey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontSize: 15,
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                  value: selectedClass,
                  hint: Text('Sınıf Seçiniz',
                      style: TextStyle(color: Colors.grey.shade600)),
                  items: classes.map((Classes classItem) {
                    // NOT: Sınıf adları veritabanında "6 A" formatında (boşluklu)
                    return DropdownMenuItem<String>(
                      value: classItem.sinifAdi,
                      child: Text(classItem.sinifAdi),
                    );
                  }).toList(),
                  onChanged: classes.isNotEmpty
                      ? (newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedClass = newValue;
                              selectedCourse = null;
                              courseClassId = null;

                              // Find class ID by name
                              final classItem = classes.firstWhere(
                                (c) => c.sinifAdi == newValue,
                                orElse: () => classes.first,
                              );

                              selectedClassId = classItem.id;

                              // Trigger class selected callback
                              widget.onClassSelected(newValue, selectedClassId);

                              // Load courses for this class
                              context.read<CourseClassBloc>().add(
                                    LoadCourseClassesByClassId(
                                        selectedClassId!),
                                  );
                            });
                          }
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, color: Colors.blueGrey.shade400, size: 18),
                SizedBox(width: 8),
                Text(
                  'Ders Seçimi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<CourseClassBloc, CourseClassState>(
              builder: (context, state) {
                final List<CourseClass> courses = state.courseClasses;

                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blueGrey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontSize: 15,
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                  value: selectedCourse,
                  hint: Text('Ders Seçiniz',
                      style: TextStyle(color: Colors.grey.shade600)),
                  items: courses
                      .where((course) =>
                          course.course != null &&
                          course.course!.dersAdi != null)
                      .map((course) {
                    return DropdownMenuItem<String>(
                      value: course.course!.dersAdi,
                      child: Text(course.course!.dersAdi),
                    );
                  }).toList(),
                  onChanged: courses.isNotEmpty && selectedClassId != null
                      ? (newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCourse = newValue;

                              // Find course ID and courseClass ID
                              final courseClass = courses.firstWhere(
                                (course) => course.course!.dersAdi == newValue,
                                orElse: () => courses.first,
                              );

                              selectedCourseId = courseClass.dersId;
                              courseClassId = courseClass.id;

                              // Trigger course selected callback
                              widget.onCourseSelected(
                                newValue,
                                selectedCourseId!,
                                courseClassId!,
                              );
                            });
                          }
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
