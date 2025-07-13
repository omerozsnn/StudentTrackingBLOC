import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/screens/homework/homework_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/homework/homework_assignment_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/homework/homework_tracking_screen.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/modern_app_header.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class HomeworkMainPage extends StatefulWidget {
  const HomeworkMainPage({super.key});

  @override
  _HomeworkMainPageState createState() => _HomeworkMainPageState();
}

class _HomeworkMainPageState extends State<HomeworkMainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              title: 'Ödev İşlemleri',
              emoji: '📝',
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
                      Icon(Icons.edit_note),
                      SizedBox(width: 8),
                      Text('Yönetim'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment),
                      SizedBox(width: 8),
                      Text('Atama'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.track_changes),
                      SizedBox(width: 8),
                      Text('Takip'),
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
                  HomeworkScreen(),
                  HomeworkAssignmentScreen(),
                  HomeworkTrackingScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 