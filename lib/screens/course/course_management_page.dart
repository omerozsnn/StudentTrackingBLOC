import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/screens/course/course_add_page.dart';
import 'package:ogrenci_takip_sistemi/screens/course/course_class_assign_page.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/modern_app_header.dart';

class CourseManagementPage extends StatefulWidget {
  const CourseManagementPage({super.key});

  @override
  _CourseManagementPageState createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ModernAppHeader(
              title: 'Ders Yönetimi',
              emoji: '📚',
              centerTitle: true,
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_note_outlined),
                      SizedBox(width: 8),
                      Text('Ders Yönetimi'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_ind_outlined),
                      SizedBox(width: 8),
                      Text('Ders Atama'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CourseAddPage(),
                  CourseClassAssignPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 