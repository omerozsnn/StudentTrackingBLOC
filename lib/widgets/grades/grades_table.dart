import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/widgets/grades/grade_cell.dart';

class GradesTable extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final Function(Map<String, dynamic>, String) onGradeTap;
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;

  const GradesTable({
    Key? key,
    required this.students,
    required this.onGradeTap,
    required this.horizontalScrollController,
    required this.verticalScrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Scrollbar(
        thumbVisibility: true,
        controller: horizontalScrollController,
        child: SingleChildScrollView(
          controller: horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Scrollbar(
            thumbVisibility: true,
            controller: verticalScrollController,
            child: SingleChildScrollView(
              controller: verticalScrollController,
              child: DataTable(
                columnSpacing: 15,
                headingRowColor:
                    MaterialStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Text('OKUL NO')),
                  DataColumn(label: Text('AD SOYAD')),
                  DataColumn(label: Text('SINAV1')),
                  DataColumn(label: Text('SINAV2')),
                  DataColumn(label: Text('SINAV3')),
                  DataColumn(label: Text('SINAV4')),
                  DataColumn(label: Text('DERS ETK1')),
                  DataColumn(label: Text('DERS ETK2')),
                  DataColumn(label: Text('DERS ETK3')),
                  DataColumn(label: Text('DERS ETK4')),
                  DataColumn(label: Text('DERS ETK5')),
                  DataColumn(label: Text('PROJE1')),
                  DataColumn(label: Text('PROJE2')),
                  DataColumn(label: Text('DÖNEM P.')),
                ],
                rows: students.map((student) {
                  return DataRow(
                    cells: [
                      DataCell(Text(student['ogrenci_no'] ?? '')),
                      DataCell(Text(student['ad_soyad'] ?? '')),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'sinav1',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'sinav2',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'sinav3',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'sinav4',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'ders_etkinlikleri1',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'ders_etkinlikleri2',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'ders_etkinlikleri3',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'ders_etkinlikleri4',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'ders_etkinlikleri5',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'proje1',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'proje2',
                        onTap: onGradeTap,
                      )),
                      DataCell(GradeCell(
                        student: student,
                        gradeType: 'donem_puani',
                        onTap: onGradeTap,
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
