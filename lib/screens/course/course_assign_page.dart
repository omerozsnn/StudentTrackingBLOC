import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/screens/course/course_class_assign_page.dart';

class CourseAssignPage extends StatelessWidget {
  const CourseAssignPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Eski sayfadan yeni sayfaya yönlendirme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CourseClassAssignPage(),
        ),
      );
    });

    // Geçiş sırasında gösterilecek yükleme ekranı
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 