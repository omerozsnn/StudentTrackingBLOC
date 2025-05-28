import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student/student_bloc.dart';
import '../../blocs/student/student_event.dart';
import '../../blocs/student/student_state.dart';
import '../../blocs/student_homework/student_homework_bloc.dart';
import '../../blocs/student_homework/student_homework_event.dart';
import '../../blocs/student_homework/student_homework_state.dart';
import '../../blocs/homework_tracking/homework_tracking_bloc.dart';
import '../../blocs/homework_tracking/homework_tracking_event.dart';
import '../../blocs/homework_tracking/homework_tracking_state.dart';
import '../../models/homework_tracking_model.dart';
import '../../utils/ui_helpers.dart';

class ClassHomeworkTrackingScreen extends StatefulWidget {
  final String className;

  const ClassHomeworkTrackingScreen({Key? key, required this.className})
      : super(key: key);

  @override
  _ClassHomeworkTrackingScreenState createState() =>
      _ClassHomeworkTrackingScreenState();
}

class _ClassHomeworkTrackingScreenState
    extends State<ClassHomeworkTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Sınıftaki öğrencileri yükle
    context.read<StudentBloc>().add(LoadStudentsByClass(widget.className));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} Sınıfı Ödev Takibi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudentsLoaded) {
            if (state.students.isEmpty) {
              return const Center(
                  child: Text('Bu sınıfta öğrenci bulunmamaktadır.'));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.className} Sınıfı Öğrencileri',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.students.length,
                      itemBuilder: (context, index) {
                        final student = state.students[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ExpansionTile(
                            title: Text(student.adSoyad ?? 'İsimsiz Öğrenci'),
                            subtitle: Text('Öğrenci No: ${student.ogrenciNo}'),
                            children: [
                              BlocBuilder<StudentHomeworkBloc,
                                  StudentHomeworkState>(
                                builder: (context, homeworkState) {
                                  // Öğrenci ödevlerini yükle
                                  if (student.id != null &&
                                      homeworkState.studentHomeworks.isEmpty) {
                                    context.read<StudentHomeworkBloc>().add(
                                          LoadStudentHomeworksByStudentId(
                                              student.id!),
                                        );
                                  }

                                  if (homeworkState.status ==
                                      StudentHomeworkStatus.loading) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final studentHomeworks = homeworkState
                                      .studentHomeworks
                                      .where((hw) => hw.ogrenciId == student.id)
                                      .toList();

                                  if (studentHomeworks.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                          'Bu öğrenciye atanmış ödev bulunmamaktadır.'),
                                    );
                                  }

                                  return Column(
                                    children: studentHomeworks.map((homework) {
                                      return ListTile(
                                        title: Text(homework.odev?.toString() ??
                                            'Ödev bilgisi yok'),
                                        subtitle:
                                            Text('Ödev ID: ${homework.odevId}'),
                                        trailing: BlocBuilder<
                                            HomeworkTrackingBloc,
                                            HomeworkTrackingState>(
                                          builder: (context, trackingState) {
                                            // Ödev takip durumunu göster
                                            final trackingRecord = trackingState
                                                .trackingRecords
                                                .firstWhere(
                                              (track) =>
                                                  track.ogrenciOdevleriId ==
                                                  homework.id,
                                              orElse: () => HomeworkTracking(
                                                ogrenciOdevleriId: homework.id!,
                                                durum: 'bilinmiyor',
                                              ),
                                            );

                                            return Chip(
                                              label: Text(
                                                trackingRecord.durum == 'yapti'
                                                    ? 'Yapıldı'
                                                    : 'Yapılmadı',
                                              ),
                                              backgroundColor:
                                                  trackingRecord.durum ==
                                                          'yapti'
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade100,
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Öğrenci listesi yüklenemedi'));
        },
      ),
    );
  }
}
