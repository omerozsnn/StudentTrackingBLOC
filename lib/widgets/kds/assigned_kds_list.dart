import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/kds_class_model.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';

class AssignedKdsList extends StatelessWidget {
  final String className;
  final List<KdsClass> assignedKdsList;
  final Function(int kdsId, int classId) onDeleteKds;
  final VoidCallback onRefresh;

  const AssignedKdsList({
    Key? key,
    required this.className,
    required this.assignedKdsList,
    required this.onDeleteKds,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$className Sınıfına Atanmış KDS'ler",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toplam ${assignedKdsList.length} KDS',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
                tooltip: 'Listeyi Yenile',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (assignedKdsList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Bu sınıfa atanmış KDS bulunmamaktadır.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assignedKdsList.length,
              itemBuilder: (context, index) {
                final kds = assignedKdsList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      kds.kdsName ?? 'KDS Adı',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Soru Sayısı: ${kds.questionCount ?? 0}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDeleteKds(context, kds),
                      tooltip: 'KDS\'yi Kaldır',
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // KDS silme onayı dialogu
  Future<void> _confirmDeleteKds(BuildContext context, KdsClass kds) async {
    // Skip the dialog if IDs are null
    if (kds.kdsId == null || kds.classId == null) {
      UIHelpers.showErrorMessage(context, 'KDS veya sınıf ID eksik');
      return;
    }

    return UIHelpers.showConfirmationDialog(
      context: context,
      title: 'KDS\'yi Kaldır',
      content:
          'Bu KDS\'yi $className sınıfından kaldırmak istediğinize emin misiniz?',
    ).then((confirmed) {
      if (confirmed) {
        onDeleteKds(kds.kdsId!, kds.classId!);
      }
    });
  }
}
