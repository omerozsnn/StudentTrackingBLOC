import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../blocs/student/student_bloc.dart';
import '../../blocs/student/student_event.dart';
import '../../blocs/student/student_state.dart';
import '../../blocs/class/class_bloc.dart';
import '../../blocs/class/class_event.dart';
import '../../blocs/class/class_state.dart';
import '../../models/classes_model.dart';
import '../../utils/ui_helpers.dart';

class StudentAddDetailedPage extends StatefulWidget {
  const StudentAddDetailedPage({super.key});

  @override
  _StudentAddDetailedPageState createState() => _StudentAddDetailedPageState();
}

class _StudentAddDetailedPageState extends State<StudentAddDetailedPage> {
  // Controllers for form fields
  final TextEditingController tcKimlikController = TextEditingController();
  final TextEditingController adSoyadController = TextEditingController();
  final TextEditingController ogrenciNoController = TextEditingController();
  final TextEditingController adresController = TextEditingController();
  final TextEditingController anneAdiController = TextEditingController();
  final TextEditingController babaAdiController = TextEditingController();
  final TextEditingController anneBabaIletisimNoController =
      TextEditingController();
  final TextEditingController veliMeslegiController = TextEditingController();
  final TextEditingController cinsiyetiController = TextEditingController();
  final TextEditingController dogumTarihiController = TextEditingController();
  final TextEditingController yasiController = TextEditingController();
  final TextEditingController babaCepTelefonuController =
      TextEditingController();
  final TextEditingController babaMeslegiIsiController =
      TextEditingController();
  final TextEditingController babaIsAdresiController = TextEditingController();
  final TextEditingController babaEgitimDurumuController =
      TextEditingController();
  final TextEditingController veliEvAdresiController = TextEditingController();
  final TextEditingController anneCepTelefonuController =
      TextEditingController();
  final TextEditingController anneEgitimDurumuController =
      TextEditingController();
  final TextEditingController anneIsTelefonuController =
      TextEditingController();
  final TextEditingController anneIsAdresiController = TextEditingController();
  final TextEditingController anneBabaDurumuController =
      TextEditingController();
  final TextEditingController kiminleKaliyorController =
      TextEditingController();
  final TextEditingController veliKimController = TextEditingController();
  final TextEditingController ilaveAciklamaController = TextEditingController();
  final TextEditingController imagePathController = TextEditingController();

  File? selectedImageFile;
  int _currentStep = 0;
  bool _isSubmitting = false;

  final List<String> egitimDurumlari = [
    'İlkokul',
    'Ortaokul',
    'Lise',
    'Üniversite',
    'Yüksek Lisans',
    'Doktora'
  ];

  final List<String> cinsiyetler = ['Erkek', 'Kız'];

  @override
  void initState() {
    super.initState();
    // Load classes for dropdown when page initializes
    context.read<ClassBloc>().add(const LoadClassesForDropdown());
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    tcKimlikController.dispose();
    adSoyadController.dispose();
    ogrenciNoController.dispose();
    adresController.dispose();
    anneAdiController.dispose();
    babaAdiController.dispose();
    anneBabaIletisimNoController.dispose();
    veliMeslegiController.dispose();
    cinsiyetiController.dispose();
    dogumTarihiController.dispose();
    yasiController.dispose();
    babaCepTelefonuController.dispose();
    babaMeslegiIsiController.dispose();
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
    imagePathController.dispose();
    super.dispose();
  }

  // Add student using BLoC
  void _addStudent() {
    // Get selected class from ClassBloc
    final classState = context.read<ClassBloc>().state;
    final selectedClass = classState is ClassesLoaded ? classState.selectedClass : null;

    if (selectedClass == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir sınıf seçin.');
      return;
    }

    if (adSoyadController.text.isEmpty) {
      UIHelpers.showErrorMessage(context, 'Ad Soyad alanı boş olamaz.');
      return;
    }

    if (selectedImageFile == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir öğrenci resmi seçin.');
      return;
    }

    setState(() => _isSubmitting = true);

    // Create student data
    final studentData = {
      "tc_kimlik": tcKimlikController.text.isEmpty
          ? null
          : tcKimlikController.text,
      "ad_soyad": adSoyadController.text,
      "sinif_id": selectedClass.id,
      "ogrenci_no": ogrenciNoController.text,
      "cinsiyeti": cinsiyetiController.text,
      "dogum_tarihi": dogumTarihiController.text,
      "yasi": yasiController.text.isEmpty ? null : int.parse(yasiController.text),
      "baba_cep_telefonu": babaCepTelefonuController.text,
      "baba_meslegi_isi": babaMeslegiIsiController.text,
      "baba_is_adresi": babaIsAdresiController.text,
      "baba_egitim_durumu": babaEgitimDurumuController.text,
      "veli_ev_adresi": veliEvAdresiController.text,
      "anne_cep_telefonu": anneCepTelefonuController.text,
      "anne_egitim_durumu": anneEgitimDurumuController.text,
      "anne_is_telefonu": anneIsTelefonuController.text,
      "anne_is_adresi": anneIsAdresiController.text,
      "anne_baba_durumu": anneBabaDurumuController.text,
      "kiminle_kaliyor": kiminleKaliyorController.text,
      "veli_kim": veliKimController.text,
      "ilave_aciklama": ilaveAciklamaController.text,
      "anne_adi": anneAdiController.text,
      "baba_adi": babaAdiController.text,
    };

    // Dispatch AddStudent event to StudentBloc
    context.read<StudentBloc>().add(AddStudent(studentData, imageFile: selectedImageFile));
  }

  // Select student image
  Future<void> _selectStudentImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        selectedImageFile = File(result.files.single.path!);
        imagePathController.text = result.files.single.path!;
      });
    }
  }

  // Select date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dogumTarihiController.text =
            "${picked.day}/${picked.month}/${picked.year}";
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentOperationSuccess) {
          setState(() => _isSubmitting = false);
          
          // Show success message
          UIHelpers.showSuccessDialog(
            context: context, 
            title: 'Başarılı', 
            message: state.message,
            onConfirm: () {
              Navigator.pop(context, true); // Return true to indicate success
            }
          );
        } else if (state is StudentError) {
          setState(() => _isSubmitting = false);
          UIHelpers.showErrorMessage(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detaylı Öğrenci Ekleme'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                setState(() {
                  if (_currentStep < 3) {
                    _currentStep += 1;
                  } else {
                    _addStudent();
                  }
                });
              },
              onStepCancel: () {
                setState(() {
                  if (_currentStep > 0) {
                    _currentStep -= 1;
                  }
                });
              },
              steps: [
                // Step 1: Basic Information
                Step(
                  title: const Text('Temel Bilgiler'),
                  content: Column(
                    children: [
                      TextFormField(
                        controller: tcKimlikController,
                        decoration: const InputDecoration(
                          labelText: 'TC Kimlik',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: adSoyadController,
                        decoration: const InputDecoration(
                          labelText: 'Ad Soyad',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildClassDropdown(),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: ogrenciNoController,
                        decoration: const InputDecoration(
                          labelText: 'Öğrenci No',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: cinsiyetiController.text.isEmpty
                            ? null
                            : cinsiyetiController.text,
                        decoration: const InputDecoration(
                          labelText: 'Cinsiyet',
                          border: OutlineInputBorder(),
                        ),
                        items: cinsiyetler.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            cinsiyetiController.text = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: dogumTarihiController,
                        decoration: InputDecoration(
                          labelText: 'Doğum Tarihi',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectDate,
                          ),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: yasiController,
                        decoration: const InputDecoration(
                          labelText: 'Yaş',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: imagePathController,
                              decoration: const InputDecoration(
                                labelText: 'Resim Yolu',
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _selectStudentImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Resim Seç'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                ),

                // Step 2: Father Information
                Step(
                  title: const Text('Baba Bilgileri'),
                  content: Column(
                    children: [
                      TextFormField(
                        controller: babaAdiController,
                        decoration: const InputDecoration(
                          labelText: 'Baba Adı',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: babaCepTelefonuController,
                        decoration: const InputDecoration(
                          labelText: 'Baba Cep Telefonu',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: babaMeslegiIsiController,
                        decoration: const InputDecoration(
                          labelText: 'Baba Mesleği/İşi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: babaIsAdresiController,
                        decoration: const InputDecoration(
                          labelText: 'Baba İş Adresi',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: babaEgitimDurumuController.text.isEmpty
                            ? null
                            : babaEgitimDurumuController.text,
                        decoration: const InputDecoration(
                          labelText: 'Baba Eğitim Durumu',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            egitimDurumlari.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            babaEgitimDurumuController.text = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                ),

                // Step 3: Mother Information
                Step(
                  title: const Text('Anne Bilgileri'),
                  content: Column(
                    children: [
                      TextFormField(
                        controller: anneAdiController,
                        decoration: const InputDecoration(
                          labelText: 'Anne Adı',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: anneCepTelefonuController,
                        decoration: const InputDecoration(
                          labelText: 'Anne Cep Telefonu',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: anneIsTelefonuController,
                        decoration: const InputDecoration(
                          labelText: 'Anne İş Telefonu',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: anneIsAdresiController,
                        decoration: const InputDecoration(
                          labelText: 'Anne İş Adresi',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: anneEgitimDurumuController.text.isEmpty
                            ? null
                            : anneEgitimDurumuController.text,
                        decoration: const InputDecoration(
                          labelText: 'Anne Eğitim Durumu',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            egitimDurumlari.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            anneEgitimDurumuController.text = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                ),

                // Step 4: Additional Information
                Step(
                  title: const Text('Ek Bilgiler'),
                  content: Column(
                    children: [
                      TextFormField(
                        controller: veliEvAdresiController,
                        decoration: const InputDecoration(
                          labelText: 'Veli Ev Adresi',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: anneBabaDurumuController,
                        decoration: const InputDecoration(
                          labelText: 'Anne/Baba Durumu (Birlikte, Ayrı, vb.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: kiminleKaliyorController,
                        decoration: const InputDecoration(
                          labelText: 'Kiminle Kalıyor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: veliKimController,
                        decoration: const InputDecoration(
                          labelText: 'Veli Kim',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: ilaveAciklamaController,
                        decoration: const InputDecoration(
                          labelText: 'İlave Açıklama',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 3,
                ),
              ],
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

  // Class Dropdown
  Widget _buildClassDropdown() {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        // Show loading indicator while loading classes
        if (state is ClassLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        // Get classes list and selected class
        final classes = state is ClassesLoaded ? state.classes : <Classes>[];
        final selectedClass = state is ClassesLoaded ? state.selectedClass : null;
        
        // Show error if no classes available
        if (classes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Sınıf bulunamadı. Lütfen önce sınıf ekleyin.'),
          );
        }
        
        // Build dropdown
        return DropdownButtonFormField<Classes>(
          value: selectedClass,
          decoration: const InputDecoration(
            labelText: 'Sınıf',
            border: OutlineInputBorder(),
          ),
          items: classes.map<DropdownMenuItem<Classes>>((Classes classItem) {
            return DropdownMenuItem<Classes>(
              value: classItem,
              child: Text(classItem.sinifAdi),
            );
          }).toList(),
          onChanged: (Classes? newValue) {
            if (newValue != null) {
              context.read<ClassBloc>().add(SelectClass(newValue));
            }
          },
        );
      },
    );
  }
} 