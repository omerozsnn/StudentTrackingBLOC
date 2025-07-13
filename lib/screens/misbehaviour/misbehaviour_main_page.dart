import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/screens/misbehaviour/misbehaviour_control_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/misbehaviour/misbehaviour_management_screen.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/modern_app_header.dart';

class MisbehaviourMainPage extends StatefulWidget {
  const MisbehaviourMainPage({super.key});

  @override
  _MisbehaviourMainPageState createState() => _MisbehaviourMainPageState();
}

class _MisbehaviourMainPageState extends State<MisbehaviourMainPage>
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
      body: Column(
        children: [
          ModernAppHeader(
            title: 'Davranış Yönetimi',
            emoji: '🧠',
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Davranış Tanımlama'),
              Tab(text: 'Davranış Kontrol'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MisbehaviourManagementScreen(),
                MisbehaviourControlScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 