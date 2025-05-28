import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherService {
  static const String _teacherIdKey = 'teacher_id';
  static const String _teacherNameKey = 'teacher_name';
  static const String _teacherImageKey = 'teacher_image_path';

  Future<void> saveTeacherInfo(int id, String name, String? imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_teacherIdKey, id);
    await prefs.setString(_teacherNameKey, name);
    if (imagePath != null) {
      await prefs.setString(_teacherImageKey, imagePath);
    }
  }

  Future<Map<String, dynamic>?> getTeacherInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_teacherIdKey);
    final name = prefs.getString(_teacherNameKey);
    final imagePath = prefs.getString(_teacherImageKey);

    if (id != null && name != null) {
      return {
        'id': id,
        'name': name,
        'imagePath': imagePath,
      };
    }
    return null;
  }

  Future<bool> hasTeacher() async {
    final info = await getTeacherInfo();
    return info != null;
  }

  // 📌 **SharedPreferences'ı temizleme**
  Future<void> clearTeacherInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_teacherIdKey);
    await prefs.remove(_teacherNameKey);
    await prefs.remove(_teacherImageKey);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // Öğretmen resmi varsa dosyayı sil
    final imagePath = prefs.getString(_teacherImageKey);
    if (imagePath != null) {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }

    // Tüm SharedPreferences verilerini temizle
    await prefs.clear();

    print('Tüm öğretmen verileri temizlendi');
  }
}
