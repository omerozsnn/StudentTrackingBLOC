import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_bloc.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

class StudentListWidget extends StatefulWidget {
  final List<Student> students;
  final Function(Student, bool, bool) onStudentStatusChanged;
  final bool isEnabled;
  final ScrollController? scrollController;

  const StudentListWidget({
    Key? key,
    required this.students,
    required this.onStudentStatusChanged,
    this.isEnabled = true,
    this.scrollController,
  }) : super(key: key);

  @override
  State<StudentListWidget> createState() => _StudentListWidgetState();
}

class _StudentListWidgetState extends State<StudentListWidget> {
  late ScrollController _studentListController;

  @override
  void initState() {
    super.initState();
    _studentListController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _studentListController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 1200;
    final bool isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    final bool isSmallScreen = screenWidth <= 800;

    // DefterKitapBloc'a erişim
    final defterKitapBloc = BlocProvider.of<DefterKitapBloc>(context);

    // Dinamik genişlikleri hesapla
    final double numberColumnWidth =
        isSmallScreen ? 40 : (isLargeScreen ? screenWidth * 0.06 : 60);
    final double nameColumnWidth = isSmallScreen
        ? screenWidth * 0.35
        : (isLargeScreen ? screenWidth * 0.55 : screenWidth * 0.40);
    final double checkboxColumnWidth =
        isSmallScreen ? 40 : (isLargeScreen ? 50 : 50);

    return Column(
      children: [
        // Header Row
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 24 : (isSmallScreen ? 8 : 16),
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: numberColumnWidth,
                child: _buildHeaderText('No'),
              ),
              SizedBox(
                width: nameColumnWidth,
                child: _buildHeaderText('Adı Soyadı',
                    textAlign:
                        isSmallScreen ? TextAlign.left : TextAlign.center),
              ),
              SizedBox(
                width: checkboxColumnWidth,
                child: _buildHeaderText('Def.'),
              ),
              SizedBox(
                width: checkboxColumnWidth,
                child: _buildHeaderText('Kit.'),
              ),
            ],
          ),
        ),

        // Student List
        Expanded(
          child: widget.students.isEmpty
              ? _buildEmptyMessage()
              : ListView.builder(
                  controller: _studentListController,
                  itemCount: widget.students.length,
                  itemBuilder: (context, index) {
                    final student = widget.students[index];
                    // Defter ve kitap durumlarını bloc üzerinden alıyoruz
                    final bool notebookStatus =
                        defterKitapBloc.getStudentNotebookStatus(student.id);
                    final bool bookStatus =
                        defterKitapBloc.getStudentBookStatus(student.id);

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            isLargeScreen ? 24 : (isSmallScreen ? 8 : 16),
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.grey.shade100
                            : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: numberColumnWidth,
                            child: _buildStudentText(
                              student.ogrenciNo.toString(),
                            ),
                          ),
                          SizedBox(
                            width: nameColumnWidth,
                            child: _buildStudentText(
                              student.adSoyad,
                              textAlign: isSmallScreen
                                  ? TextAlign.left
                                  : TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: checkboxColumnWidth,
                            child: _buildCheckbox(
                              student,
                              defterKitapBloc,
                              notebookStatus,
                              'notebook',
                            ),
                          ),
                          SizedBox(
                            width: checkboxColumnWidth,
                            child: _buildCheckbox(
                              student,
                              defterKitapBloc,
                              bookStatus,
                              'book',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Helper methods for UI components
  Widget _buildHeaderText(String text,
      {double? width, TextAlign textAlign = TextAlign.center}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: textAlign,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildStudentText(String text,
      {double? width, TextAlign textAlign = TextAlign.center}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }

  Widget _buildCheckbox(
      Student student, DefterKitapBloc bloc, bool value, String key) {
    return SizedBox(
      child: Transform.scale(
        scale: 1.2,
        child: Checkbox(
          value: value,
          activeColor: Colors.green,
          onChanged: widget.isEnabled
              ? (bool? newValue) {
                  if (newValue != null) {
                    // Checkbox değiştiğinde bloc üzerindeki değerleri güncelliyoruz
                    // ancak bu sadece local bir değişiklik olacak, API'ye istek atılmayacak
                    if (key == 'notebook') {
                      bloc.setStudentNotebookStatus(student.id, newValue);
                    } else {
                      bloc.setStudentBookStatus(student.id, newValue);
                    }

                    setState(() {
                      // Sadece UI'yı yeniliyoruz
                    });

                    // Ana widget'a durumu bildir - buradan toplu kayıt yapılacak
                    widget.onStudentStatusChanged(
                      student,
                      bloc.getStudentNotebookStatus(student.id),
                      bloc.getStudentBookStatus(student.id),
                    );
                  }
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptyMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 50, color: Colors.orangeAccent),
          const SizedBox(height: 10),
          Text(
            'Öğrenci bulunamadı!',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
