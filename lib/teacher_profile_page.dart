import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/teacher_model.dart';
import 'service/teacher_service.dart';
import 'api.dart/teacherApi.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TeacherProfilePage extends StatefulWidget {
  @override
  _TeacherProfilePageState createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  String? teacherName;
  String? teacherImage;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  late int teacherId; // Öğretmen ID'sini sakla

  @override
  void initState() {
    super.initState();
    fetchTeacherInfo();
  }

  Future<void> fetchTeacherInfo() async {
    final teacherService = TeacherService();
    final teacherInfo = await teacherService.getTeacherInfo();

    if (teacherInfo != null) {
      setState(() {
        teacherId = teacherInfo['id'];
        teacherName = teacherInfo['name'];
        teacherImage = teacherImage;
      });
    }
    if (teacherImage == null) {
      final apiService = TeacherApiService(baseUrl: 'http://localhost:3000');
      teacherImage = await apiService.getTeacherImage(teacherId);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> updateTeacher() async {
    if (teacherName == null || teacherName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen adınızı girin!')),
      );
      return;
    }

    final apiService = TeacherApiService(baseUrl: 'http://localhost:3000');
    bool success = await apiService.updateTeacherInfo(
        teacherId, teacherName!, _selectedImage);

    if (success) {
      // ✅ Backend'den gelen yeni bilgileri çek
      final updatedTeacher = await apiService.getTeacher(teacherId);

      if (updatedTeacher != null) {
        setState(() {
          teacherName = updatedTeacher.teacherName;
          teacherImage = updatedTeacher.teacherImage;
        });

        // ✅ Güncellenmiş bilgileri SharedPreferences’a kaydet
        final teacherService = TeacherService();
        await teacherService.saveTeacherInfo(
            teacherId, teacherName!, teacherImage);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilgiler başarıyla güncellendi!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme başarısız, tekrar deneyin.')),
      );
    }
  }

  Future<void> deleteTeacherAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
            'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      final apiService = TeacherApiService(baseUrl: 'http://localhost:3000');
      final success = await apiService.deleteTeacher(teacherId);

      if (success) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Hesap silinemedi. Lütfen tekrar deneyin.')),
          );
        }
      }
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
            colors: [Color(0xFF6C8997), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Üst Başlık
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Profil Ayarları',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 40), // Denge için
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Profil Resmi
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
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
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : teacherImage != null
                                  ? NetworkImage(teacherImage!) as ImageProvider
                                  : const AssetImage(
                                      'assets/default_avatar.png'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C8997),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Ad Soyad Alanı
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
                      controller: TextEditingController(text: teacherName),
                      onChanged: (value) => setState(() => teacherName = value),
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

                  // Güncelleme Butonu
                  ElevatedButton(
                    onPressed: updateTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C8997),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Bilgileri Güncelle',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hesabı Silme Butonu
                  TextButton.icon(
                    onPressed: deleteTeacherAccount,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      'Hesabı Sil',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
