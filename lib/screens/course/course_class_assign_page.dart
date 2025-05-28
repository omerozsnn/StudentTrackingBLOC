import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_state.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/course_classes_model.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/dropdown_card.dart';
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart' as classApi;

class CourseClassAssignPage extends StatefulWidget {
  const CourseClassAssignPage({super.key});

  @override
  _CourseClassAssignPageState createState() => _CourseClassAssignPageState();
}

class _CourseClassAssignPageState extends State<CourseClassAssignPage> {
  // API services
  final classApi.ApiService classApiService =
      classApi.ApiService(baseUrl: 'http://localhost:3000');

  // State variables
  List<Classes> classes = [];
  Classes? selectedClass;
  Course? selectedCourse;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadClasses();
    // Load courses through BLoC
    context.read<CourseBloc>().add(LoadCoursesForDropdown());
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadClasses() async {
    try {
      final data = await classApiService.getClassesForDropdown();
      if (mounted) {
        setState(() {
          classes = data.map<Classes>((classItem) => classItem).toList();
        });
      }
    } catch (error) {
      if (mounted) {
        UIHelpers.showErrorMessage(context, 'Sınıflar yüklenemedi: $error');
      }
    }
  }

  Future<void> _assignCourseToClass() async {
    if (selectedClass == null || selectedCourse == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir sınıf ve ders seçin.');
      return;
    }

    UIHelpers.showLoadingDialog(context, 'Ders sınıfa atanıyor...');

    try {
      final newCourseClass = CourseClass(
        id: 0, // auto incremented by the database
        sinifId: selectedClass!.id,
        dersId: selectedCourse!.id,
      );

      context.read<CourseClassBloc>().add(AddCourseClass(newCourseClass));
    } catch (error) {
      if (mounted) {
        UIHelpers.hideLoadingDialog(context);
        UIHelpers.showErrorMessage(context, 'Ders atama işlemi başarısız oldu: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Atama'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : BlocListener<CourseClassBloc, CourseClassState>(
              listener: (context, state) {
                if (state is CourseClassLoading) {
                  // Yükleme durumu için bir şey yapmaya gerek yok,
                  // çünkü zaten _assignCourseToClass içinde dialog gösteriyoruz
                } else if (state is CourseClassOperationSuccess) {
                  UIHelpers.hideLoadingDialog(context);
                  UIHelpers.showSuccessDialog(
                    context: context,
                    title: 'Başarılı',
                    message: state.message,
                    onConfirm: () {
                      setState(() {
                        selectedClass = null;
                        selectedCourse = null;
                      });
                    },
                  );
                } else if (state is CourseClassError) {
                  UIHelpers.hideLoadingDialog(context);
                  UIHelpers.showErrorMessage(context, state.message);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class selection card
                    DropdownCard<Classes>(
                      title: 'Sınıf Seçin',
                      hint: 'Sınıf Seçin',
                      selectedValue: selectedClass,
                      items: classes,
                      onChanged: (newValue) {
                        setState(() {
                          selectedClass = newValue;
                        });
                      },
                      getLabel: (Classes cls) => cls.sinifAdi,
                    ),
                    
                    // Course selection card
                    BlocBuilder<CourseBloc, CourseState>(
                      builder: (context, state) {
                        if (state is CourseLoading) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        } else if (state is CoursesLoaded) {
                          return DropdownCard<Course>(
                            title: 'Ders Seçin',
                            hint: 'Ders Seçin',
                            selectedValue: selectedCourse,
                            items: state.courses,
                            onChanged: (newValue) {
                              setState(() {
                                selectedCourse = newValue;
                              });
                            },
                            getLabel: (Course course) => course.dersAdi,
                          );
                        } else if (state is CourseError) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Hata: ${state.message}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          );
                        }
                        return const Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Dersler yüklenemiyor'),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Assign button
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.assignment_turned_in, color: Colors.white),
                        label: const Text(
                          'Dersi Sınıfa Ata',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _assignCourseToClass,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 