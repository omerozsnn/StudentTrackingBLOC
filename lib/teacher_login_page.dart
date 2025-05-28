// teacher_login_page.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ogrenci_takip_sistemi/main.dart';
import 'api.dart/teacherApi.dart';
import 'service/teacher_service.dart';

class TeacherLoginPage extends StatefulWidget {
  @override
  _TeacherLoginPageState createState() => _TeacherLoginPageState();
}

class _TeacherLoginPageState extends State<TeacherLoginPage> {
  final TeacherApiService _apiService =
      TeacherApiService(baseUrl: 'http://localhost:3000');
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  // Pastel color scheme
  static const Color primaryColor = Color(0xFFB5D5C5); // Pastel mint green
  static const Color secondaryColor = Color(0xFFEAC7C7); // Pastel pink
  static const Color accentColor = Color(0xFFC08261); // Pastel brown
  static const Color backgroundColor = Color(0xFFF5E9CF); // Pastel cream

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveTeacher() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen adınızı giriniz')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Öğretmen bilgilerini kaydet
      final teacher = await _apiService.createTeacher({
        'teacher_name': _nameController.text,
      });

      String? imageUrl;

      // 2. Resim yükleme işlemi
      if (_selectedImage != null) {
        try {
          imageUrl =
              await _apiService.uploadTeacherImage(teacher.id, _selectedImage!);
          if (imageUrl == null) {
            throw Exception('Resim yüklenemedi');
          }
        } catch (e) {
          print('Resim yükleme hatası: $e');
          // Resim yükleme hatası olsa bile devam et
        }
      }

      // 3. SharedPreferences'a kaydet
      final teacherService = TeacherService();
      await teacherService.saveTeacherInfo(
        teacher.id,
        teacher.teacherName,
        imageUrl, // null olabilir
      );

      // 4. Ana sayfaya yönlendir
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
              toggleTheme: () {
                if (context.mounted) {
                  setState(() {});
                }
              },
              isDarkTheme: false,
            ),
          ),
        );
      }
    } catch (e) {
      print('Kayıt hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt başarısız: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, backgroundColor],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Öğretmen Kaydı',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Profile Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 4,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Color(0xFF6C8997),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Fotoğraf Ekle',
                                        style: TextStyle(
                                          color: Color(0xFF6C8997),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        if (_selectedImage != null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C8997),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Name Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Ad Soyad',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon:
                          const Icon(Icons.person, color: Color(0xFF6C8997)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Submit Button
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF6C8997),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _saveTeacher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C8997),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Kaydet ve Devam Et',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
