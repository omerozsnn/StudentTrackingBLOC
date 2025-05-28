import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'dart:io';

import '../../models/classes_model.dart';

class StudentUpdateScreen extends StatefulWidget {
  final Student student;

  const StudentUpdateScreen({super.key, required this.student});

  @override
  _StudentUpdateScreenState createState() => _StudentUpdateScreenState();
}

class _StudentUpdateScreenState extends State<StudentUpdateScreen> {
  late TextEditingController tcKimlikController;
  late TextEditingController adSoyadController;
  late TextEditingController ogrenciNoController;
  late TextEditingController cinsiyetController;
  late TextEditingController dogumTarihiController;
  late TextEditingController yasiController;
  late TextEditingController babaCepTelefonuController;
  late TextEditingController babaMeslegiController;
  late TextEditingController babaIsAdresiController;
  late TextEditingController babaEgitimDurumuController;
  late TextEditingController veliEvAdresiController;
  late TextEditingController anneCepTelefonuController;
  late TextEditingController anneEgitimDurumuController;
  late TextEditingController anneIsTelefonuController;
  late TextEditingController anneIsAdresiController;
  late TextEditingController anneBabaDurumuController;
  late TextEditingController kiminleKaliyorController;
  late TextEditingController veliKimController;
  late TextEditingController ilaveAciklamaController;
  late TextEditingController anneAdiController;
  late TextEditingController babaAdiController;
  late TextEditingController resimYoluController;

  File? selectedImageFile;
  String? selectedClass;
  List<Map<String, dynamic>> classes = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with student data
    tcKimlikController =
        TextEditingController(text: widget.student.tcKimlik?.toString() ?? '');
    adSoyadController = TextEditingController(text: widget.student.adSoyad);
    ogrenciNoController =
        TextEditingController(text: widget.student.ogrenciNo?.toString() ?? '');
    cinsiyetController =
        TextEditingController(text: widget.student.cinsiyeti ?? '');
    dogumTarihiController =
        TextEditingController(text: widget.student.dogumTarihi ?? '');
    yasiController =
        TextEditingController(text: widget.student.yasi?.toString() ?? '');
    babaCepTelefonuController =
        TextEditingController(text: widget.student.babaCepTelefonu ?? '');
    babaMeslegiController =
        TextEditingController(text: widget.student.babaMeslegiIsi ?? '');
    babaIsAdresiController =
        TextEditingController(text: widget.student.babaIsAdresi ?? '');
    babaEgitimDurumuController =
        TextEditingController(text: widget.student.babaEgitimDurumu ?? '');
    veliEvAdresiController =
        TextEditingController(text: widget.student.veliEvAdresi ?? '');
    anneCepTelefonuController =
        TextEditingController(text: widget.student.anneCepTelefonu ?? '');
    anneEgitimDurumuController =
        TextEditingController(text: widget.student.anneEgitimDurumu ?? '');
    anneIsTelefonuController =
        TextEditingController(text: widget.student.anneIsTelefonu ?? '');
    anneIsAdresiController =
        TextEditingController(text: widget.student.anneIsAdresi ?? '');
    anneBabaDurumuController =
        TextEditingController(text: widget.student.anneBabaDurumu ?? '');
    kiminleKaliyorController =
        TextEditingController(text: widget.student.kiminleKaliyor ?? '');
    veliKimController =
        TextEditingController(text: widget.student.veliKim ?? '');
    ilaveAciklamaController =
        TextEditingController(text: widget.student.ilaveAciklama ?? '');
    anneAdiController =
        TextEditingController(text: widget.student.anneAdi ?? '');
    babaAdiController =
        TextEditingController(text: widget.student.babaAdi ?? '');
    resimYoluController =
        TextEditingController(text: widget.student.resimYolu ?? '');

    // Load classes for dropdown
    _loadClasses();
  }

  @override
  void dispose() {
    // Dispose all controllers
    tcKimlikController.dispose();
    adSoyadController.dispose();
    ogrenciNoController.dispose();
    cinsiyetController.dispose();
    dogumTarihiController.dispose();
    yasiController.dispose();
    babaCepTelefonuController.dispose();
    babaMeslegiController.dispose();
    babaIsAdresiController.dispose();
    babaEgitimDurumuController.dispose();
    veliEvAdresiController.dispose();
    anneCepTelefonuController.dispose();
    anneEgitimDurumuController.dispose();
    anneIsTelefonuController.dispose();
    anneIsAdresiController.dispose();
    anneBabaDurumuController.dispose();
    kiminleKaliyorController.dispose();
    veliKimController.dispose();
    ilaveAciklamaController.dispose();
    anneAdiController.dispose();
    babaAdiController.dispose();
    resimYoluController.dispose();
    super.dispose();
  }

  void _loadClasses() {
    // Load classes via BLoC
    context.read<ClassBloc>().add(const LoadClassesForDropdown());
  }

  // Resim seçme işlemi (File Picker ile)
  Future<void> _selectStudentImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        selectedImageFile = File(result.files.single.path!);
        resimYoluController.text = result.files.single.path!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resim seçilmedi.')),
      );
    }
  }

  void _updateStudent() {
    setState(() => _isSubmitting = true);

    try {
      // Get the selected class ID from the ClassBloc
      final classState = context.read<ClassBloc>().state;
      final selectedClassId =
          classState is ClassesLoaded && classState.selectedClass != null
              ? classState.selectedClass!.id
              : null;

      // Create a map with only the changed fields
      Map<String, dynamic> updateData = {};

      // Class ID check
      if (selectedClassId != null) {
        updateData['sinif_id'] = selectedClassId.toString();
      }

      // TC Kimlik check
      if (tcKimlikController.text.isNotEmpty) {
        updateData['tc_kimlik'] = tcKimlikController.text;
      }

      // Basic checks for other fields
      if (adSoyadController.text != widget.student.adSoyad) {
        updateData['ad_soyad'] = adSoyadController.text;
      }
      if (ogrenciNoController.text != widget.student.ogrenciNo) {
        updateData['ogrenci_no'] = ogrenciNoController.text;
      }
      if (cinsiyetController.text != widget.student.cinsiyeti) {
        updateData['cinsiyeti'] = cinsiyetController.text;
      }

      // Doğum tarihi kontrolü ve formatlaması
      if (dogumTarihiController.text != widget.student.dogumTarihi) {
        updateData['dogum_tarihi'] = dogumTarihiController.text;
      }

      if (yasiController.text.isNotEmpty) {
        final yasi = int.tryParse(yasiController.text);
        if (yasi != null && yasi.toString() != widget.student.yasi.toString()) {
          updateData['yasi'] = yasi;
        }
      }

      if (babaCepTelefonuController.text != widget.student.babaCepTelefonu) {
        updateData['baba_cep_telefonu'] = babaCepTelefonuController.text;
      }

      if (babaMeslegiController.text != widget.student.babaMeslegiIsi) {
        updateData['baba_meslegi_isi'] = babaMeslegiController.text;
      }

      if (babaIsAdresiController.text != widget.student.babaIsAdresi) {
        updateData['baba_is_adresi'] = babaIsAdresiController.text;
      }

      if (babaEgitimDurumuController.text != widget.student.babaEgitimDurumu) {
        updateData['baba_egitim_durumu'] = babaEgitimDurumuController.text;
      }

      if (veliEvAdresiController.text != widget.student.veliEvAdresi) {
        updateData['veli_ev_adresi'] = veliEvAdresiController.text;
      }

      if (anneCepTelefonuController.text != widget.student.anneCepTelefonu) {
        updateData['anne_cep_telefonu'] = anneCepTelefonuController.text;
      }

      if (anneEgitimDurumuController.text != widget.student.anneEgitimDurumu) {
        updateData['anne_egitim_durumu'] = anneEgitimDurumuController.text;
      }

      if (anneIsAdresiController.text != widget.student.anneIsAdresi) {
        updateData['anne_is_adresi'] = anneIsAdresiController.text;
      }

      if (anneIsTelefonuController.text != widget.student.anneIsTelefonu) {
        updateData['anne_is_telefonu'] = anneIsTelefonuController.text;
      }

      if (anneBabaDurumuController.text != widget.student.anneBabaDurumu) {
        updateData['anne_baba_durumu'] = anneBabaDurumuController.text;
      }

      if (kiminleKaliyorController.text != widget.student.kiminleKaliyor) {
        updateData['kiminle_kaliyor'] = kiminleKaliyorController.text;
      }

      if (veliKimController.text != widget.student.veliKim) {
        updateData['veli_kim'] = veliKimController.text;
      }

      if (ilaveAciklamaController.text != widget.student.ilaveAciklama) {
        updateData['ilave_aciklama'] = ilaveAciklamaController.text;
      }

      if (anneAdiController.text != widget.student.anneAdi) {
        updateData['anne_adi'] = anneAdiController.text;
      }

      if (babaAdiController.text != widget.student.babaAdi) {
        updateData['baba_adi'] = babaAdiController.text;
      }

      // Only update if there are changes
      if (updateData.isNotEmpty) {
        // Add the UpdateStudent event to the bloc
        context.read<StudentBloc>().add(UpdateStudent(
            widget.student.id, updateData,
            imageFile: selectedImageFile));
      } else {
        setState(() => _isSubmitting = false);
        UIHelpers.showInfoMessage(context, 'Değişiklik yapılmadı.');
      }
    } catch (error) {
      setState(() => _isSubmitting = false);
      UIHelpers.showErrorMessage(
          context, 'Güncelleme sırasında hata oluştu: $error');
    }
  }

  final Color primaryColor = const Color(0xFF9DC88D);
  final Color secondaryColor = const Color(0xFFB5D4A7);
  final Color accentColor = const Color(0xFF86A97D);
  final Color lightColor = const Color(0xFFE6EFE3);
  final Color darkColor = const Color(0xFF5F7A4C);
  final Color textColor = const Color(0xFF374D29);

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentOperationSuccess) {
          setState(() => _isSubmitting = false);
          UIHelpers.showSuccessDialog(
              context: context,
              title: 'Başarılı',
              message: state.message,
              onConfirm: () {
                Navigator.pop(context, true); // Return true to indicate success
              });
        } else if (state is StudentError) {
          setState(() => _isSubmitting = false);
          UIHelpers.showErrorMessage(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Öğrenci Güncelle'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [lightColor, Colors.white],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Temel Bilgiler Kartı
                      _buildCard(
                        'Temel Bilgiler',
                        [
                          _buildTextField('TC Kimlik', tcKimlikController),
                          _buildTextField('Ad Soyad', adSoyadController),
                          _buildClassDropdown(),
                          _buildTextField('Öğrenci No', ogrenciNoController),
                          _buildTextField('Cinsiyet', cinsiyetController),
                          _buildDateField(
                              'Doğum Tarihi', dogumTarihiController),
                          _buildTextField('Yaşı', yasiController),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Baba Bilgileri Kartı
                      _buildCard(
                        'Baba Bilgileri',
                        [
                          _buildTextField('Baba Adı', babaAdiController),
                          _buildTextField(
                              'Baba Cep Telefonu', babaCepTelefonuController),
                          _buildTextField(
                              'Baba Mesleği', babaMeslegiController),
                          _buildTextField(
                              'Baba İş Adresi', babaIsAdresiController),
                          _buildTextField(
                              'Baba Eğitim Durumu', babaEgitimDurumuController),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Anne Bilgileri Kartı
                      _buildCard(
                        'Anne Bilgileri',
                        [
                          _buildTextField('Anne Adı', anneAdiController),
                          _buildTextField(
                              'Anne Cep Telefonu', anneCepTelefonuController),
                          _buildTextField(
                              'Anne İş Telefonu', anneIsTelefonuController),
                          _buildTextField(
                              'Anne İş Adresi', anneIsAdresiController),
                          _buildTextField(
                              'Anne Eğitim Durumu', anneEgitimDurumuController),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Veli Bilgileri Kartı
                      _buildCard(
                        'Veli/İletişim Bilgileri',
                        [
                          _buildTextField(
                              'Anne Baba Durumu', anneBabaDurumuController),
                          _buildTextField(
                              'Kiminle Kalıyor', kiminleKaliyorController),
                          _buildTextField('Velisi Kim', veliKimController),
                          _buildTextField(
                              'Veli Ev Adresi', veliEvAdresiController),
                          _buildTextField(
                              'İlave Açıklama', ilaveAciklamaController,
                              maxLines: 3),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Fotoğraf Kartı
                      _buildCard(
                        'Fotoğraf',
                        [
                          // Fotoğraf container'ı
                          Center(
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: selectedImageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        selectedImageFile!,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : widget.student.photoData != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.memory(
                                            widget.student.photoData!,
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.photo_library,
                                                  size: 48, color: Colors.grey),
                                              const SizedBox(height: 8),
                                              const Text('Fotoğraf yok'),
                                            ],
                                          ),
                                        ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Fotoğraf seçme butonu
                          ElevatedButton.icon(
                            onPressed: _selectStudentImage,
                            icon: const Icon(Icons.photo_camera),
                            label: const Text('Fotoğraf Seç'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Güncelleme Butonu
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _updateStudent,
                          icon: const Icon(Icons.save),
                          label: const Text('Değişiklikleri Kaydet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Loading overlay
            if (_isSubmitting || _isLoading())
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Check if any BLoC is in loading state
  bool _isLoading() {
    final studentState = context.watch<StudentBloc>().state;
    final classState = context.watch<ClassBloc>().state;
    return studentState is StudentLoading || classState is ClassLoading;
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.deepPurpleAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: secondaryColor),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  controller.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                  // Calculate age
                  final now = DateTime.now();
                  int age = now.year - picked.year;
                  if (now.month < picked.month ||
                      (now.month == picked.month && now.day < picked.day)) {
                    age--;
                  }
                  yasiController.text = age.toString();
                });
              }
            },
          ),
        ),
        controller: controller,
        readOnly: true,
      ),
    );
  }

  Widget _buildClassDropdown() {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        if (state is ClassLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ClassError) {
          return Text('Error: ${state.message}');
        }

        final classes = state is ClassesLoaded ? state.classes : [];

        // Find the current class of the student
        final selectedClassItem = state is ClassesLoaded
            ? state.classes.firstWhere(
                (classItem) =>
                    classItem.id.toString() ==
                    widget.student.sinifId.toString(),
                orElse: () => state.classes.first,
              )
            : null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DropdownButtonFormField<dynamic>(
            decoration: InputDecoration(
              labelText: 'Sınıf',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            value: selectedClassItem,
            items: classes.map((classItem) {
              return DropdownMenuItem(
                value: classItem,
                child: Text(classItem.sinifAdi),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<ClassBloc>().add(SelectClass(value));
              }
            },
          ),
        );
      },
    );
  }
}
