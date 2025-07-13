import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import '../../blocs/homework_tracking/homework_tracking_bloc.dart';
import '../../blocs/homework_tracking/homework_tracking_event.dart';
import '../../blocs/homework_tracking/homework_tracking_state.dart';
import '../../blocs/class/class_bloc.dart';
import '../../blocs/class/class_event.dart';
import '../../blocs/class/class_state.dart';
import '../../blocs/student/student_bloc.dart';
import '../../blocs/student/student_event.dart';
import '../../blocs/student/student_state.dart';
import '../../blocs/homework/homework_bloc.dart';
import '../../blocs/homework/homework_event.dart';
import '../../blocs/homework/homework_state.dart';
import '../../blocs/student_homework/student_homework_bloc.dart';
import '../../blocs/student_homework/student_homework_event.dart';
import '../../blocs/student_homework/student_homework_state.dart';

import '../../models/homework_tracking_model.dart';
import '../../models/classes_model.dart';
import '../../models/homework_model.dart';
import '../../models/student_homework_model.dart';

import '../../utils/ui_helpers.dart';
import '../../widgets/homework/class_selector.dart';
import '../homework/homework_screen.dart';
import '../student/student_homework_tracking_screen.dart';
import '../class/class_homework_tracking_screen.dart';

class HomeworkTrackingScreen extends StatefulWidget {
  const HomeworkTrackingScreen({Key? key}) : super(key: key);

  @override
  _HomeworkTrackingScreenState createState() => _HomeworkTrackingScreenState();
}

class _HomeworkTrackingScreenState extends State<HomeworkTrackingScreen> {
  Classes? _selectedClass;
  Homework? _selectedHomework;
  Map<String, dynamic>? _selectedStudent;
  Map<int, String> _selectedStatuses = {};
  Map<int, String> _comments = {};
  Map<int, TextEditingController> _commentControllers = {};
  Uint8List? _studentImage;

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<ClassBloc>().add(LoadClasses());
  }

  void _handleClassSelected(Classes? classItem) {
    setState(() {
      _selectedClass = classItem;
      _selectedStudent = null;
      _selectedHomework = null;
      _studentImage = null;
      _selectedStatuses.clear();
      _comments.clear();
    });

    if (classItem != null) {
      // Load students for this class
      context.read<StudentBloc>().add(LoadStudentsByClass(classItem.sinifAdi));

      // Load homework assignments for this class
      final classId = classItem.id;
      if (classId != null) {
        context.read<StudentHomeworkBloc>().add(
              LoadStudentsByClassAndHomework(
                  classId, 0), // 0 means load all homeworks
            );
      }
    }
  }

  void _handleHomeworkSelected(int homeworkId) {
    if (_selectedClass == null) return;

    // Find the homework from the state
    final homeworkState = context.read<HomeworkBloc>().state;
    final homework = homeworkState.homeworks.firstWhere(
      (h) => h.id == homeworkId,
      orElse: () => throw Exception('Homework not found'),
    );

    setState(() {
      _selectedHomework = homework;
    });

    // Load tracking data for this homework
    final studentState = context.read<StudentBloc>().state;
    if (studentState is StudentsLoaded) {
      final studentIds = studentState.students.map((s) => s.id!).toList();

      context.read<HomeworkTrackingBloc>().add(
            BulkGetHomeworkTrackingForHomework(studentIds, homeworkId),
          );

      // Initialize status and comments for all students
      for (final student in studentState.students) {
        if (!_selectedStatuses.containsKey(student.id)) {
          _selectedStatuses[student.id!] = 'yapti'; // Default status
        }

        if (!_commentControllers.containsKey(student.id)) {
          _commentControllers[student.id!] = TextEditingController();
        }
      }
    }
  }

  Future<void> _saveAllHomeworkTracking() async {
    if (_selectedHomework == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir ödev seçin');
      return;
    }

    if (_selectedClass == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir sınıf seçin');
      return;
    }

    final studentState = context.read<StudentBloc>().state;
    if (!(studentState is StudentsLoaded) || studentState.students.isEmpty) {
      UIHelpers.showErrorMessage(context, 'Öğrenci listesi boş');
      return;
    }

    try {
      // Get student homework records for the selected homework
      final studentHomeworkState = context.read<StudentHomeworkBloc>().state;
      final studentHomeworks = studentHomeworkState.studentHomeworks;

      // Create tracking records for each student
      List<HomeworkTracking> trackingList = [];

      for (final student in studentState.students) {
        // Find the student homework record for this student
        final studentHomework = studentHomeworks.firstWhere(
          (sh) =>
              sh.ogrenciId == student.id && sh.odevId == _selectedHomework!.id,
          orElse: () => throw Exception('Student homework record not found'),
        );

        trackingList.add(HomeworkTracking(
          ogrenciOdevleriId: studentHomework.id!,
          durum: _selectedStatuses[student.id] ?? 'yapti',
          aciklama: _comments[student.id] ?? '',
        ));
      }

      // Bulk upsert tracking records
      context.read<HomeworkTrackingBloc>().add(
            BulkUpsertHomeworkTracking(trackingList),
          );

      UIHelpers.showSuccessMessage(
        context,
        'Ödev takip bilgileri başarıyla kaydedildi',
      );
    } catch (e) {
      UIHelpers.showErrorMessage(
        context,
        'Ödev takip bilgileri kaydedilirken hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> _loadStudentImage(int studentId) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/student/$studentId/image'));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        setState(() {
          _studentImage = response.bodyBytes;
        });
      }
    } catch (error) {
      print('Resim yüklenemedi: $error');
    }
  }

  void _navigateToStudentHomeworkTrackingPage(int studentId) {
    if (_selectedStudent != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StudentHomeworkTrackingScreen(studentId: studentId),
        ),
      );
    } else {
      UIHelpers.showErrorMessage(context, 'Lütfen önce bir öğrenci seçin');
    }
  }

  void _navigateToClassHomeworkTrackingPage() {
    if (_selectedClass != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ClassHomeworkTrackingScreen(className: _selectedClass!.sinifAdi),
        ),
      );
    } else {
      UIHelpers.showErrorMessage(context, 'Lütfen önce bir sınıf seçin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('Sınıf Takip Listesi'),
                onPressed: _navigateToClassHomeworkTrackingPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          // Headers
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text('Sınıflar',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Text('Sınıfa Atanan Ödevler',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Text('Öğrenci Bilgileri',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Spacer(),
            ],
          ),

          // Main Content Area
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Panel: Class List
                SizedBox(
                  width: 150,
                  child: _buildClassList(),
                ),
                const SizedBox(width: 16.0),

                // Middle and Right Panels
                Expanded(
                  flex: 4,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildHomeworkList()),
                      const SizedBox(width: 50.0),
                      Expanded(flex: 2, child: _buildStudentInfo()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Section: Student List
          Expanded(
            child: Card(
              elevation: 2,
              child: _buildStudentList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList() {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        if (state is ClassLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListView.builder(
            itemCount: state.classes.length,
            itemBuilder: (context, index) {
              final classItem = state.classes[index];
              final bool isSelected = _selectedClass?.id == classItem.id;

              return GestureDetector(
                onTap: () => _handleClassSelected(classItem),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: ListTile(
                    title: Text(
                      classItem.sinifAdi,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHomeworkList() {
    return BlocBuilder<HomeworkBloc, HomeworkState>(
      builder: (context, state) {
        if (state.status == HomeworkStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: ListView.builder(
            itemCount: state.homeworks.length,
            itemBuilder: (context, index) {
              final homework = state.homeworks[index];
              final bool isSelected = _selectedHomework?.id == homework.id;

              return Card(
                color: isSelected ? Colors.blueGrey[100] : Colors.white,
                elevation: isSelected ? 6 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isSelected
                      ? const BorderSide(color: Colors.blueGrey, width: 2)
                      : BorderSide.none,
                ),
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                child: ListTile(
                  title: Text(
                    homework.odevAdi,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blueGrey : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Teslim: ${homework.teslimTarihi.toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blueGrey)
                      : const Icon(Icons.circle_outlined, color: Colors.grey),
                  onTap: () {
                    if (homework.id != null) {
                      _handleHomeworkSelected(homework.id!);
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentInfo() {
    if (_selectedStudent == null) {
      return const Column(
        children: [
          SizedBox(height: 80),
          Text(
            'Öğrenci seçilmedi',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Card(
          elevation: 4,
          child: Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: _studentImage != null
                ? Image.memory(_studentImage!, fit: BoxFit.cover)
                : const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 100),
          child: Column(
            children: [
              Text(
                _selectedStudent!['ogrenci_no']?.toString() ?? '',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedStudent!['ad_soyad'] ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: _saveAllHomeworkTracking,
                    icon: const Icon(Icons.save),
                  ),
                  const SizedBox(width: 35),
                  IconButton(
                    onPressed: () => _navigateToStudentHomeworkTrackingPage(
                        _selectedStudent!['id']),
                    icon: const Icon(Icons.print),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        if (state is StudentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StudentsLoaded) {
          return Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 80, child: Text('Numara')),
                    Expanded(child: Text('Adı Soyadı')),
                    SizedBox(width: 200, child: Text('Durum')),
                    SizedBox(width: 400, child: Text('Açıklama')),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.students.length,
                  itemBuilder: (context, index) {
                    final student = state.students[index];
                    final studentId = student.id!;
                    final bool isSelected = _selectedStudent != null &&
                        _selectedStudent!['id'] == studentId;

                    // Get or create comment controller for this student
                    final commentController = _commentControllers.putIfAbsent(
                        studentId, () => TextEditingController());

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueGrey.shade100
                            : (_selectedStatuses[studentId] == 'yapti'
                                ? const Color.fromARGB(255, 111, 249, 116)
                                : const Color.fromARGB(255, 190, 76, 68)),
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: ListTile(
                        leading: Text(student.ogrenciNo?.toString() ?? ''),
                        title: Text(student.adSoyad ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Checkbox for yapti/yapmadi
                            Checkbox(
                              value: _selectedStatuses[studentId] == 'yapti',
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedStatuses[studentId] =
                                      value! ? 'yapti' : 'yapmadi';
                                });
                              },
                            ),
                            const SizedBox(width: 150),
                            // Açıklama alanı ve dropdown
                            SizedBox(
                              width: 400,
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: commentController,
                                          decoration: const InputDecoration(
                                            hintText: 'Açıklama ekleyin...',
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                          ),
                                          style: const TextStyle(fontSize: 14),
                                          onChanged: (value) {
                                            _comments[studentId] = value;
                                          },
                                        ),
                                      ),
                                      Container(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        child: PopupMenuButton<String>(
                                          icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.blueGrey),
                                          tooltip: 'Hızlı Açıklama Seç',
                                          offset: const Offset(0, 40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          onSelected: (String value) {
                                            setState(() {
                                              commentController.text = value;
                                              _comments[studentId] = value;
                                            });
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            const PopupMenuItem(
                                              value: 'Okula Gelmedi',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.person_off,
                                                      size: 20,
                                                      color: Colors.grey),
                                                  SizedBox(width: 8),
                                                  Text('Okula Gelmedi'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuDivider(),
                                            const PopupMenuItem(
                                              value: 'Ödevini Getirmedi',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.assignment_late,
                                                      size: 20,
                                                      color: Colors.grey),
                                                  SizedBox(width: 8),
                                                  Text('Ödevini Getirmedi'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedStudent = {
                              'id': student.id,
                              'ogrenci_no': student.ogrenciNo,
                              'ad_soyad': student.adSoyad,
                            };
                            _studentImage = null;
                          });
                          // Load student image
                          if (student.id != null) {
                            _loadStudentImage(student.id!);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('Öğrenci listesi yüklenemedi'));
      },
    );
  }
}
