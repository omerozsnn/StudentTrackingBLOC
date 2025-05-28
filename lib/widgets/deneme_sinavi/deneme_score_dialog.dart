import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_event.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/custom_button.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';

// Local model for storing deneme scores
class DenemeScores {
  final int dogru;
  final int yanlis;
  final int bos;
  final int puan;

  DenemeScores({
    this.dogru = 0,
    this.yanlis = 0,
    this.bos = 0,
    this.puan = 0,
  });

  Map<String, dynamic> toJson() => {
        'dogru': dogru,
        'yanlis': yanlis,
        'bos': bos,
        'puan': puan,
      };

  factory DenemeScores.fromJson(Map<String, dynamic> json) => DenemeScores(
        dogru: json['dogru'] ?? 0,
        yanlis: json['yanlis'] ?? 0,
        bos: json['bos'] ?? 0,
        puan: json['puan'] ?? 0,
      );
}

class DenemeScoreDialog extends StatelessWidget {
  final int studentId;
  final int denemeId;
  final Map<int, Map<int, DenemeScores>> studentDenemeScores;
  final Function(String) onSuccess;
  final Function(String) onError;

  const DenemeScoreDialog({
    Key? key,
    required this.studentId,
    required this.denemeId,
    required this.studentDenemeScores,
    required this.onSuccess,
    required this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController dogruController = TextEditingController();
    TextEditingController yanlisController = TextEditingController();
    TextEditingController bosController = TextEditingController();
    TextEditingController puanController = TextEditingController();

    // Fill existing values if available
    if (studentDenemeScores[studentId]?[denemeId] != null) {
      final scores = studentDenemeScores[studentId]![denemeId]!;
      dogruController.text = scores.dogru.toString();
      yanlisController.text = scores.yanlis.toString();
      bosController.text = scores.bos.toString();
      puanController.text = scores.puan.toString();
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          const Text('Sınav Sonuçları'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dogruController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Doğru',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.check_circle_outline,
                          color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: yanlisController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Yanlış',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon:
                          const Icon(Icons.cancel_outlined, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: bosController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Boş',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.remove_circle_outline,
                          color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: puanController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Puan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      prefixIcon: const Icon(Icons.score, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('İptal', style: TextStyle(color: Colors.grey.shade700)),
        ),
        CustomButton(
          text: 'Kaydet',
          icon: Icons.save,
          backgroundColor: Colors.blue.shade700,
          onPressed: () => _saveScores(context, dogruController,
              yanlisController, bosController, puanController),
        ),
      ],
    );
  }

  void _saveScores(
    BuildContext context,
    TextEditingController dogruController,
    TextEditingController yanlisController,
    TextEditingController bosController,
    TextEditingController puanController,
  ) {
    try {
      final scores = DenemeScores(
        dogru: int.tryParse(dogruController.text) ?? 0,
        yanlis: int.tryParse(yanlisController.text) ?? 0,
        bos: int.tryParse(bosController.text) ?? 0,
        puan: int.tryParse(puanController.text) ?? 0,
      );

      final data = {
        'dogru': scores.dogru,
        'yanlis': scores.yanlis,
        'bos': scores.bos,
        'puan': scores.puan,
      };

      if (studentDenemeScores[studentId]?[denemeId] != null) {
        // Update existing score
        context.read<OgrenciDenemeBloc>().add(
              UpdateOgrenciDenemeResult(
                ogrenciId: studentId,
                denemeSinaviId: denemeId,
                data: data,
              ),
            );
      } else {
        // Add new score
        final result = StudentExamResult(
          ogrenciId: studentId,
          denemeSinaviId: denemeId,
          dogru: scores.dogru,
          yanlis: scores.yanlis,
          bos: scores.bos,
          puan: scores.puan,
        );
        context.read<OgrenciDenemeBloc>().add(
              AddOgrenciDenemeResult(result),
            );
      }

      Navigator.of(context).pop();
      onSuccess('Puanlar başarıyla kaydedildi');
    } catch (e) {
      onError('Geçerli değerler giriniz');
    }
  }
}
