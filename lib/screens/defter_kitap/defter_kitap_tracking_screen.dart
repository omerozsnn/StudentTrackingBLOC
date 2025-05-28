import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_state.dart';
import 'package:ogrenci_takip_sistemi/extensions/student_notebook_extension.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/widgets/defter_kitap/class_course_selector_widget.dart';
import 'package:ogrenci_takip_sistemi/widgets/defter_kitap/date_selector_widget.dart';
import 'package:ogrenci_takip_sistemi/widgets/defter_kitap/student_list_widget.dart';
import 'package:ogrenci_takip_sistemi/utils/snackbar_helper.dart';
import 'package:ogrenci_takip_sistemi/screens/defter_kitap/class_notebook_pdf.dart';

class DefterKitapTrackingScreen extends StatefulWidget {
  const DefterKitapTrackingScreen({super.key});

  @override
  _DefterKitapTrackingScreenState createState() =>
      _DefterKitapTrackingScreenState();
}

class _DefterKitapTrackingScreenState extends State<DefterKitapTrackingScreen> {
  String? selectedClass;
  int? selectedClassId;
  String? selectedCourse;
  int? selectedCourseId;
  int? courseClassId;
  DateTime selectedDate = DateTime.now();
  List<Student> students = [];
  List<String> availableDates = [];

  @override
  void initState() {
    super.initState();
  }

  void _navigateToClassNotebookPage() {
    if (selectedClass != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ClassNotebookBookTrackingPage(className: selectedClass!),
        ),
      );
    } else {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Lütfen önce bir sınıf seçin',
      );
    }
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  void _handleClassSelected(String className, int? classId) {
    print('Seçilen sınıf: [$className], ID: $classId');

    setState(() {
      selectedClass = className;
      selectedClassId = classId;
      selectedCourse = null;
      selectedCourseId = null;
      courseClassId = null;
      students = [];
      availableDates = [];
    });
  }

  void _handleCourseSelected(
      String courseName, int courseId, int courseClassId) {
    setState(() {
      selectedCourse = courseName;
      selectedCourseId = courseId;
      this.courseClassId = courseClassId;
    });

    // Load dates for this course class
    context.read<DefterKitapBloc>().add(LoadDefterKitapDates(courseClassId));
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });

    if (courseClassId != null) {
      // Load records for this date and course class
      context.read<DefterKitapBloc>().add(
            LoadDefterKitapByDate(
              _formatDateForDisplay(date),
              courseClassId!,
            ),
          );
    }
  }

  void _handleStudentStatusChanged(
      Student student, bool notebookStatus, bool bookStatus) {
    // Sadece local değişikliği göster, API'ye istek atma
    setState(() {
      // Bloc üzerindeki değerleri güncelle ama API'ye gönderme
      final defterKitapBloc = BlocProvider.of<DefterKitapBloc>(context);
      defterKitapBloc.setStudentNotebookStatus(student.id, notebookStatus);
      defterKitapBloc.setStudentBookStatus(student.id, bookStatus);
    });

    // API isteği burada yapılmayacak
  }

  void _handleSaveRequested() {
    if (courseClassId == null || students.isEmpty) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Kaydetmek için sınıf, ders ve öğrenci bilgileri gereklidir',
      );
      return;
    }

    // DefterKitapBloc'a erişim
    final defterKitapBloc = BlocProvider.of<DefterKitapBloc>(context);

    // Prepare data for API
    List<Map<String, dynamic>> defterKitapDataList = [];
    for (final student in students) {
      // Öğrencinin defter ve kitap durumlarını bloc üzerinden al
      final bool notebookStatus =
          defterKitapBloc.getStudentNotebookStatus(student.id);
      final bool bookStatus = defterKitapBloc.getStudentBookStatus(student.id);

      defterKitapDataList.add({
        'ogrenci_id': student.id,
        'sinif_dersleri_id': courseClassId!,
        'defter_durum': notebookStatus ? 'getirdi' : 'getirmedi',
        'kitap_durum': bookStatus ? 'getirdi' : 'getirmedi',
        'tarih': _formatDateForApi(selectedDate),
      });
    }

    // Save to API via bloc - bu toplu gönderim olacak
    context.read<DefterKitapBloc>().add(
          AddOrUpdateDefterKitap(
            defterKitapDataList,
            _formatDateForDisplay(selectedDate),
            courseClassId!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    final isSmallScreen = screenWidth <= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Defter ve Kitap Takibi'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueGrey,
              ),
              onPressed: _navigateToClassNotebookPage,
              child: Text('Sınıf Takip Listesi'),
            ),
          ),
        ],
      ),
      body: BlocListener<DefterKitapBloc, DefterKitapState>(
        listener: (context, state) {
          if (state is DefterKitapError) {
            // Hafif bir error gösterip sonra gizleyeceğiz
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );

            // 2 saniye sonra SnackBar'ı kapat
            Future.delayed(Duration(seconds: 2), () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            });
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left panel - Class and course selection
            Container(
              width: isLargeScreen ? 280 : (isMediumScreen ? 250 : 220),
              constraints: BoxConstraints(
                minWidth: 200,
                maxWidth: 300,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Class and Course Selection
                    ClassCourseSelectorWidget(
                      onClassSelected: _handleClassSelected,
                      onCourseSelected: _handleCourseSelected,
                    ),

                    const SizedBox(height: 16),

                    // Date selection and available dates
                    Expanded(
                      child: BlocConsumer<DefterKitapBloc, DefterKitapState>(
                        listener: (context, state) {
                          if (state is DefterKitapError) {
                            SnackbarHelper.showErrorSnackBar(
                              context,
                              state.message,
                            );
                          } else if (state is DefterKitapOperationSuccess) {
                            SnackbarHelper.showSuccessSnackBar(
                              context,
                              state.message,
                            );

                            if (state.updatedDates != null) {
                              setState(() {
                                availableDates = state.updatedDates!;
                              });
                            }
                          } else if (state is DefterKitapDatesLoaded) {
                            setState(() {
                              availableDates = state.availableDates;

                              // If there are dates, load the most recent one
                              if (availableDates.isNotEmpty) {
                                final parts = availableDates.first.split('-');
                                selectedDate = DateTime(
                                  int.parse(parts[2]),
                                  int.parse(parts[1]),
                                  int.parse(parts[0]),
                                );

                                _handleDateSelected(selectedDate);
                              } else {
                                // If no dates, use today's date
                                _handleDateSelected(DateTime.now());
                              }
                            });
                          } else if (state is DefterKitapRecordsLoaded) {
                            setState(() {
                              students = state.students;
                            });
                          }
                        },
                        builder: (context, state) {
                          final bool isLoading =
                              state is DefterKitapLoadingState;
                          final bool isEnabled =
                              courseClassId != null && !isLoading;

                          return DateSelectorWidget(
                            onDateSelected: _handleDateSelected,
                            onSaveRequested: _handleSaveRequested,
                            initialDate: selectedDate,
                            availableDates: availableDates,
                            courseClassId: courseClassId,
                            isEnabled: isEnabled,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content - Student List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: BlocBuilder<DefterKitapBloc, DefterKitapState>(
                        builder: (context, state) {
                          final bool isLoading =
                              state is DefterKitapLoadingState;

                          if (isLoading) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 2,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(
                                      'Yükleniyor...',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Eğer öğrenci yoksa özel bir mesaj göster
                          if (students.isEmpty) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 2,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.amber,
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Öğrenci bulunamadı!',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      courseClassId == null
                                          ? 'Lütfen önce bir sınıf ve ders seçin'
                                          : availableDates.isEmpty
                                              ? 'Bu sınıf/ders için henüz kayıt yapılmamış.\nYeni bir tarih seçip "Kontrolü Kaydet" düğmesine basın.'
                                              : 'Öğrenci listesi yüklenemedi.',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 2,
                            child: StudentListWidget(
                              students: students,
                              onStudentStatusChanged:
                                  _handleStudentStatusChanged,
                              isEnabled: courseClassId != null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
