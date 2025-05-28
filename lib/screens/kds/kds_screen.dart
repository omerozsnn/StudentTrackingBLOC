import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/screens/kds/kd_add_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/kds/kds_assignment_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/kds/kds_result_screen.dart';

class KDSScreenNew extends StatefulWidget {
  const KDSScreenNew({Key? key}) : super(key: key);

  @override
  _KDSScreenNewState createState() => _KDSScreenNewState();
}

class _KDSScreenNewState extends State<KDSScreenNew>
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
      appBar: AppBar(
        title: const Text('KDS Yönetimi'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.add_circle_outline),
              text: 'KDS Ekle',
            ),
            Tab(
              icon: Icon(Icons.assignment_ind),
              text: 'KDS Atama',
            ),
            Tab(
              icon: Icon(Icons.analytics_outlined),
              text: 'KDS Sonuçları',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          KDSAddScreen(),
          KdsAssignmentScreen(),
          KdsResultScreen(),
        ],
      ),
    );
  }
}
