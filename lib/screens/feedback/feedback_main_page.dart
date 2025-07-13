import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/screens/feedback/teacher_comment_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/feedback/teacher_feedback_option_screen.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/modern_app_header.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class FeedbackMainPage extends StatefulWidget {
  const FeedbackMainPage({super.key});

  @override
  _FeedbackMainPageState createState() => _FeedbackMainPageState();
}

class _FeedbackMainPageState extends State<FeedbackMainPage>
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
              title: 'Öğretmen Görüşü',
              emoji: '🗣️',
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
                      Icon(Icons.list_alt),
                      SizedBox(width: 8),
                      Text('Görüş Seçenekleri'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_ind),
                      SizedBox(width: 8),
                      Text('Görüş Atama'),
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
                  TeacherFeedbackOptionScreen(),
                  TeacherCommentScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 