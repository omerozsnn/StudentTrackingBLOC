import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student_homework/student_homework_bloc.dart';
import '../../blocs/student_homework/student_homework_event.dart';
import '../../blocs/student_homework/student_homework_state.dart';
import '../../blocs/homework_tracking/homework_tracking_bloc.dart';
import '../../blocs/homework_tracking/homework_tracking_event.dart';
import '../../blocs/homework_tracking/homework_tracking_state.dart';
import '../../models/homework_tracking_model.dart';
import '../../utils/ui_helpers.dart';

class StudentHomeworkTrackingScreen extends StatefulWidget {
  final int studentId;

  const StudentHomeworkTrackingScreen({Key? key, required this.studentId})
      : super(key: key);

  @override
  _StudentHomeworkTrackingScreenState createState() =>
      _StudentHomeworkTrackingScreenState();
}

class _StudentHomeworkTrackingScreenState
    extends State<StudentHomeworkTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Öğrencinin ödevlerini yükle
    context
        .read<StudentHomeworkBloc>()
        .add(LoadStudentHomeworksByStudentId(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Ödev Takibi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<StudentHomeworkBloc, StudentHomeworkState>(
        builder: (context, state) {
          if (state.status == StudentHomeworkStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == StudentHomeworkStatus.error) {
            return Center(child: Text('Hata: ${state.errorMessage}'));
          }

          if (state.studentHomeworks.isEmpty) {
            return const Center(
                child: Text('Bu öğrenciye atanmış ödev bulunmamaktadır.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Öğrenci ID: ${widget.studentId}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Atanan Ödevler',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.studentHomeworks.length,
                    itemBuilder: (context, index) {
                      final homework = state.studentHomeworks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                              homework.odev?.toString() ?? 'Ödev bilgisi yok'),
                          subtitle: Text('Ödev ID: ${homework.odevId}'),
                          trailing: BlocBuilder<HomeworkTrackingBloc,
                              HomeworkTrackingState>(
                            builder: (context, trackingState) {
                              // Ödev takip durumunu göster
                              final trackingRecord =
                                  trackingState.trackingRecords.firstWhere(
                                (track) =>
                                    track.ogrenciOdevleriId == homework.id,
                                orElse: () => HomeworkTracking(
                                  ogrenciOdevleriId: homework.id!,
                                  durum: 'bilinmiyor',
                                ),
                              );

                              return Text(
                                trackingRecord.durum == 'yapti'
                                    ? 'Yapıldı'
                                    : 'Yapılmadı',
                                style: TextStyle(
                                  color: trackingRecord.durum == 'yapti'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
