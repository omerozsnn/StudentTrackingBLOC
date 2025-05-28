import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/utils/date_formatter.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';

class StudentDetailModal extends StatelessWidget {
  final Student student;

  const StudentDetailModal({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF6C8997),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${student.adSoyad} - Detaylı Bilgiler',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Color(0xFF6C8997),
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(icon: Icon(Icons.person), text: "Öğrenci"),
                        Tab(icon: Icon(Icons.woman), text: "Anne"),
                        Tab(icon: Icon(Icons.man), text: "Baba"),
                        Tab(icon: Icon(Icons.family_restroom), text: "Veli/Diğer"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildStudentTab(),
                          _buildMotherTab(),
                          _buildFatherTab(),
                          _buildGuardianTab(),
                        ],
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

  Widget _buildStudentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIHelpers.buildDetailTextField('Cinsiyet', student.cinsiyeti ?? ''),
          UIHelpers.buildDetailTextField(
            'Doğum Tarihi',
            DateFormatter.convertToLocalFormat(student.dogumTarihi ?? ''),
          ),
          UIHelpers.buildDetailTextField('Yaş', student.yasi?.toString() ?? ''),
          UIHelpers.buildDetailTextField('TC Kimlik No', student.tcKimlik?.toString() ?? ''),
        ],
      ),
    );
  }

  Widget _buildMotherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIHelpers.buildDetailTextField('Anne Adı', student.anneAdi ?? ''),
          UIHelpers.buildDetailTextField('Anne Cep Telefonu', student.anneCepTelefonu ?? ''),
          UIHelpers.buildDetailTextField('Anne İş Telefonu', student.anneIsTelefonu ?? ''),
          UIHelpers.buildDetailTextField('Anne İş Adresi', student.anneIsAdresi ?? ''),
          UIHelpers.buildDetailTextField('Anne Eğitim Durumu', student.anneEgitimDurumu ?? ''),
        ],
      ),
    );
  }

  Widget _buildFatherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIHelpers.buildDetailTextField('Baba Adı', student.babaAdi ?? ''),
          UIHelpers.buildDetailTextField('Baba Cep Telefonu', student.babaCepTelefonu ?? ''),
          UIHelpers.buildDetailTextField('Baba Mesleği', student.babaMeslegiIsi ?? ''),
          UIHelpers.buildDetailTextField('Baba İş Adresi', student.babaIsAdresi ?? ''),
          UIHelpers.buildDetailTextField('Baba Eğitim Durumu', student.babaEgitimDurumu ?? ''),
        ],
      ),
    );
  }

  Widget _buildGuardianTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIHelpers.buildDetailTextField('Anne/Baba Durumu', student.anneBabaDurumu ?? ''),
          UIHelpers.buildDetailTextField('Kiminle Kalıyor', student.kiminleKaliyor ?? ''),
          UIHelpers.buildDetailTextField('Veli Kim', student.veliKim ?? ''),
          UIHelpers.buildDetailTextField('Veli Ev Adresi', student.veliEvAdresi ?? ''),
          UIHelpers.buildDetailTextField('İlave Açıklama', student.ilaveAciklama ?? ''),
        ],
      ),
    );
  }

  static void show(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StudentDetailModal(student: student);
      },
    );
  }
} 