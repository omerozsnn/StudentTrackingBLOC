import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'student_add_detailed_page.dart';
import 'dart:io';
import '../../blocs/student/student_bloc.dart';
import '../../blocs/student/student_event.dart';
import '../../blocs/student/student_state.dart';
import '../../blocs/class/class_bloc.dart';
import '../../blocs/class/class_event.dart';
import '../../blocs/class/class_state.dart';
import '../../models/classes_model.dart';
import '../../utils/ui_helpers.dart';

class StudentAddPage extends StatefulWidget {
  const StudentAddPage({super.key});

  @override
  _StudentAddPageState createState() => _StudentAddPageState();
}

class _StudentAddPageState extends State<StudentAddPage> {
  final TextEditingController tcKimlikController = TextEditingController();
  final TextEditingController adSoyadController = TextEditingController();
  final TextEditingController ogrenciNoController = TextEditingController();
  final TextEditingController adresController = TextEditingController();
  final TextEditingController anneAdiController = TextEditingController();
  final TextEditingController babaAdiController = TextEditingController();
  final TextEditingController anneBabaIletisimNoController = TextEditingController();
  final TextEditingController veliMeslegiController = TextEditingController();
  final TextEditingController imagePathController = TextEditingController();

  File? selectedImageFile;
  bool _isSubmitting = false;

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

    setState(() => _isSubmitting = true);

    // Create student data
    final studentData = {
      "tc_kimlik": tcKimlikController.text.isEmpty
          ? null
          : int.parse(tcKimlikController.text),
      "ad_soyad": adSoyadController.text,
      "sinif_id": selectedClass.id,
      "ogrenci_no": ogrenciNoController.text,
      "veli_ev_adresi": adresController.text,
      "anne_adi": anneAdiController.text,
      "baba_adi": babaAdiController.text,
      "baba_cep_telefonu": anneBabaIletisimNoController.text,
      "baba_meslegi_isi": veliMeslegiController.text,
    };

    // Dispatch AddStudent event to StudentBloc
    context.read<StudentBloc>().add(AddStudent(studentData, imageFile: selectedImageFile));
  }

  // Clear form fields
  void _clearFormFields() {
    tcKimlikController.clear();
    adSoyadController.clear();
    ogrenciNoController.clear();
    adresController.clear();
    anneAdiController.clear();
    babaAdiController.clear();
    anneBabaIletisimNoController.clear();
    veliMeslegiController.clear();
    imagePathController.clear();
    selectedImageFile = null;
  }

  // Select student image
  Future<void> _selectStudentImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        selectedImageFile = File(result.files.single.path!);
        imagePathController.text = result.files.single.path!;
      });
    } else {
      // User canceled the picker
    }
  }

  // Import students from Excel
  Future<void> _importFromExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      // Dispatch ImportStudentsFromExcel event to StudentBloc
      context.read<StudentBloc>().add(ImportStudentsFromExcel(file));
    }
  }

  // Update students from Excel
  Future<void> _updateFromExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      // Dispatch UpdateStudentsFromExcel event to StudentBloc
      context.read<StudentBloc>().add(UpdateStudentsFromExcel(file));
    }
  }

  // Navigate to detailed student add page
  void _navigateToDetailedPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentAddDetailedPage()),
    );
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
              _clearFormFields();
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
          title: const Text('Öğrenci Ekle'),
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.deepPurpleAccent, Colors.white],
                  stops: [0.0, 0.3],
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Excel Operations Card
                    _buildExcelOperationsCard(),
                    const SizedBox(height: 16),
                    // Student Information Card
                    _buildStudentInfoCard(),
                  ],
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

  // Excel Operations Card
  Widget _buildExcelOperationsCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Excel İşlemleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _importFromExcel,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Excel\'den Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _updateFromExcel,
                    icon: const Icon(Icons.update),
                    label: const Text('Excel\'den Güncelle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Student Information Card
  Widget _buildStudentInfoCard() {
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
              'Öğrenci Bilgileri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            _buildTextField('TC Kimlik', tcKimlikController, keyboardType: TextInputType.number),
            _buildTextField('Ad Soyad', adSoyadController),
            _buildClassDropdown(),
            _buildTextField('Öğrenci No', ogrenciNoController),
            _buildTextField('Adres', adresController, maxLines: 2),
            _buildTextField('Anne Adı', anneAdiController),
            _buildTextField('Baba Adı', babaAdiController),
            _buildTextField('Anne/Baba İletişim No', anneBabaIletisimNoController, keyboardType: TextInputType.phone),
            _buildTextField('Veli Mesleği', veliMeslegiController),
            // Image selection area
            _buildImageSelectionArea(),
            const SizedBox(height: 20),
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Image Selection Area
  Widget _buildImageSelectionArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: imagePathController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Resim Yolu',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _selectStudentImage,
          icon: const Icon(Icons.image),
          label: const Text('Resim Seç'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
      ],
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _addStudent,
          icon: const Icon(Icons.person_add),
          label: const Text('Öğrenci Ekle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _navigateToDetailedPage,
          icon: const Icon(Icons.edit_note),
          label: const Text('Detaylı Bilgi Girişi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  // Text Field Builder
  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    {TextInputType keyboardType = TextInputType.text, 
    int maxLines = 1}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  // Class Dropdown
  Widget _buildClassDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: BlocBuilder<ClassBloc, ClassState>(
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
            decoration: InputDecoration(
              labelText: 'Sınıf',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
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
      ),
    );
  }
} 