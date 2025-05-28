import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_state.dart';
import 'package:ogrenci_takip_sistemi/models/kds_model.dart';
import 'package:ogrenci_takip_sistemi/models/units_model.dart';
import 'package:ogrenci_takip_sistemi/widgets/kds/kds_image_selector.dart';
import 'package:ogrenci_takip_sistemi/widgets/kds/kds_answersheet.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'package:ogrenci_takip_sistemi/kdsS%C4%B1n%C4%B1faAtamaEkran%C4%B1.dart';
import 'package:ogrenci_takip_sistemi/screens/unit/unit_screen.dart';

class KDSAddScreen extends StatefulWidget {
  const KDSAddScreen({super.key});

  @override
  _KDSAddScreenState createState() => _KDSAddScreenState();
}

class _KDSAddScreenState extends State<KDSAddScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _questionCountController =
      TextEditingController();

  List<String?> _selectedAnswers = [];
  int _questionCount = 0;

  String? selectedGradeLevel;
  Unit? selectedUnit;
  bool isAutoFormat = true;
  List<File> _selectedImages = [];

  final List<String> gradeLevels = ['5', '6', '7', '8'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load KDS list
    context.read<KDSBloc>().add(LoadKDSList());

    // Load Unit list
    context.read<UnitBloc>().add(LoadUnits());
  }

  void _updateAnswersheetSize(int count) {
    setState(() {
      _questionCount = count;
      // Mevcut cevapları koruyarak yeni boyuta getir
      List<String?> newAnswers = List.filled(count, null);
      for (int i = 0; i < _selectedAnswers.length && i < count; i++) {
        newAnswers[i] = _selectedAnswers[i];
      }
      _selectedAnswers = newAnswers;
    });
  }

  void _handleImagesSelected(List<File> images) {
    setState(() {
      _selectedImages = images;
    });
  }

  bool _hasAnyAnswer() {
    return _selectedAnswers.any((answer) => answer != null);
  }

  Future<int> _getNextKDSNumber() async {
    if (selectedUnit == null || selectedGradeLevel == null) return 1;

    final kdsState = context.read<KDSBloc>().state;
    if (kdsState is! KDSListLoaded) return 1;

    var kdsList = kdsState.kdsList;

    try {
      var unitKDSList = kdsList.where((kds) {
        List<String> parts = kds.kdsName.split('-');
        if (parts.length >= 2) {
          String kdsGradeLevel = parts[0];
          return kds.unitId == selectedUnit!.id &&
              kdsGradeLevel == selectedGradeLevel &&
              kds.kdsName.endsWith('.KDS');
        }
        return false;
      }).toList();

      List<int> existingNumbers = [];
      for (var kds in unitKDSList) {
        String kdsName = kds.kdsName;
        RegExp regExp = RegExp(r'-(\d+)\.KDS$');
        var match = regExp.firstMatch(kdsName);
        if (match != null) {
          int? number = int.tryParse(match.group(1)!);
          if (number != null) {
            existingNumbers.add(number);
          }
        }
      }

      if (existingNumbers.isEmpty) return 1;

      existingNumbers.sort();
      int expectedNumber = 1;
      for (int number in existingNumbers) {
        if (number != expectedNumber) {
          return expectedNumber;
        }
        expectedNumber++;
      }

      return existingNumbers.last + 1;
    } catch (error) {
      print('KDS sayısı hesaplanamadı: $error');
      return 1;
    }
  }

  Future<void> _updateKDSName() async {
    // Sadece isAutoFormat açıkken ve gerekli alanlar seçildiğinde otomatik ad güncelle
    if (!isAutoFormat || selectedGradeLevel == null || selectedUnit == null)
      return;

    // Extract unit number from unit name
    String? unitNumber;
    if (selectedUnit != null) {
      final RegExp regExp = RegExp(r'(\d+)');
      final match = regExp.firstMatch(selectedUnit!.unitName);
      if (match != null) {
        unitNumber = match.group(1);
      }
    }

    if (unitNumber == null) return;

    final nextNumber = await _getNextKDSNumber();
    final formattedName = '$selectedGradeLevel-$unitNumber-$nextNumber.KDS';

    setState(() {
      _nameController.text = formattedName;
    });
  }

  Map<String, dynamic> _createAnswersheet() {
    Map<String, dynamic> answersheet = {};

    for (int i = 0; i < _selectedAnswers.length; i++) {
      if (_selectedAnswers[i] != null) {
        // API'nin beklediği formatta anahtarları oluştur (q1, q2, q3, ...)
        answersheet['q${i + 1}'] = _selectedAnswers[i];
      }
    }

    return answersheet;
  }

  void _saveKDS() {
    final String name = _nameController.text;
    final String questionCountText = _questionCountController.text;
    final int? questionCount = int.tryParse(questionCountText);

    if (name.isEmpty || questionCount == null || selectedUnit == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen tüm alanları doldurun.');
      return;
    }

    try {
      // Get the current state
      final kdsState = context.read<KDSBloc>().state;
      final KDS? currentKDS = kdsState.selectedKDS;

      // Create the answersheet
      final Map<String, dynamic> answersheet = _createAnswersheet();

      if (currentKDS == null) {
        // Check if KDS with the same name exists
        if (kdsState is KDSListLoaded) {
          bool exists = kdsState.kdsList.any((kds) =>
              kds.kdsName.toLowerCase() == name.toLowerCase() &&
              kds.unitId == selectedUnit!.id);

          if (exists) {
            UIHelpers.showErrorMessage(
                context, 'Bu isimde bir KDS zaten mevcut.');
            return;
          }
        }

        // Add new KDS
        final newKDS = KDS(
          kdsName: name,
          questionCount: questionCount,
          unitId: selectedUnit!.id!,
          answersheet: answersheet,
        );

        // Boş resim listesi kontrolü ekle
        final images = _selectedImages.isNotEmpty ? _selectedImages : null;
        context.read<KDSBloc>().add(AddKDS(newKDS, images: images));
      } else {
        // Update existing KDS
        final updatedKDS = KDS(
          id: currentKDS.id,
          kdsName: name,
          questionCount: questionCount,
          unitId: selectedUnit!.id!,
          answersheet: answersheet,
        );

        // Boş resim listesi kontrolü ekle
        final images = _selectedImages.isNotEmpty ? _selectedImages : null;
        context.read<KDSBloc>().add(UpdateKDS(updatedKDS, images: images));
      }
    } catch (error) {
      UIHelpers.showErrorMessage(
          context, 'KDS kaydedilirken bir hata oluştu: $error');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _questionCountController.clear();
    setState(() {
      selectedUnit = null;
      selectedGradeLevel = null;
      _selectedImages = [];
      _selectedAnswers = [];
      _questionCount = 0;
      isAutoFormat = true;
    });

    // Clear selected KDS in BLoC
    context.read<KDSBloc>().add(SelectKDS(null));
  }

  void _confirmDeleteKDS(int id) {
    UIHelpers.showConfirmationDialog(
      context: context,
      title: 'KDS Sil',
      content:
          'Bu KDS\'yi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
    ).then((confirmed) {
      if (confirmed) {
        context.read<KDSBloc>().add(DeleteKDS(id));
      }
    });
  }

  void _showAnswersheetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create a temporary copy of the answers for the dialog
        List<String?> tempAnswers = List.from(_selectedAnswers);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Cevap Anahtarı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: KDSAnswerSheet(
                questionCount: _questionCount,
                initialAnswers: tempAnswers,
                onAnswersChanged: (answers) {
                  tempAnswers = answers;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    ).then((saved) {
      if (saved == true) {
        setState(() {
          _selectedAnswers = List.from(_selectedAnswers);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KDS Yönetimi'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          // Ünite Ekleme butonu
          IconButton(
            icon: const Icon(Icons.library_add),
            tooltip: 'Ünite Ekle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UnitScreen(),
                ),
              ).then((_) {
                // Ünite listesini yenile
                context.read<UnitBloc>().add(LoadUnits());
              });
            },
          ),
          // KDS Kontrol butonu
          IconButton(
            icon: const Icon(Icons.assignment_ind),
            tooltip: 'KDS Atama',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssignKDSPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<KDSBloc, KDSState>(
        listener: (context, state) {
          if (state is KDSOperationSuccess) {
            UIHelpers.showSuccessMessage(context, state.message);
            if (state.message.contains('eklendi') ||
                state.message.contains('silindi')) {
              _clearForm();
            }
          } else if (state is KDSError) {
            UIHelpers.showErrorMessage(context, state.message);
          } else if (state is KDSSelected) {
            // Update form with selected KDS data
            final kds = state.selectedKDS!;
            setState(() {
              _nameController.text = kds.kdsName;
              _questionCountController.text = kds.questionCount.toString();
              _updateAnswersheetSize(kds.questionCount);

              // Set selected unit
              final units = context.read<UnitBloc>().units;
              selectedUnit = units.firstWhere(
                (unit) => unit.id == kds.unitId,
                orElse: () => Unit(unitName: ''),
              );

              // Extract grade level from KDS name
              List<String> parts = kds.kdsName.split('-');
              if (parts.isNotEmpty) {
                selectedGradeLevel = parts[0];
              }

              // Load answersheet data
              if (kds.answersheet != null) {
                kds.answersheet!.forEach((key, value) {
                  int? index = int.tryParse(key.replaceAll('q', ''));
                  if (index != null && index > 0 && index <= _questionCount) {
                    _selectedAnswers[index - 1] = value.toString();
                  }
                });
              }

              isAutoFormat = false; // Disable auto format when editing
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Otomatik format switch'i
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 20, color: Colors.deepPurple.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Otomatik Format: ${selectedGradeLevel != null && selectedUnit != null ? "$selectedGradeLevel-${_extractUnitNumber(selectedUnit!.unitName)}-X.KDS" : "Sınıf-Ünite-Sıra.KDS"}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isAutoFormat,
                      onChanged: (value) {
                        setState(() {
                          isAutoFormat = value;
                          if (value &&
                              selectedGradeLevel != null &&
                              selectedUnit != null) {
                            _updateKDSName();
                          }
                        });
                      },
                      activeColor: Colors.deepPurpleAccent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Sınıf ve Ünite seçimi yan yana
              Row(
                children: [
                  // Sınıf düzeyi seçimi
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text('Sınıf'),
                          value: selectedGradeLevel,
                          isExpanded: true,
                          items: gradeLevels
                              .map<DropdownMenuItem<String>>((String level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text('$level. Sınıf'),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedGradeLevel = newValue;
                              if (isAutoFormat) {
                                _updateKDSName();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Ünite seçimi
                  Expanded(
                    flex: 3,
                    child: BlocBuilder<UnitBloc, UnitState>(
                      builder: (context, unitState) {
                        final units = unitState.units;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Unit>(
                              hint: const Text('Ünite Seçiniz'),
                              value: selectedUnit,
                              isExpanded: true,
                              items: units
                                  .map<DropdownMenuItem<Unit>>((Unit unit) {
                                return DropdownMenuItem<Unit>(
                                  value: unit,
                                  child: Text(unit.unitName),
                                );
                              }).toList(),
                              onChanged: (Unit? newValue) {
                                setState(() {
                                  selectedUnit = newValue;
                                  if (isAutoFormat &&
                                      selectedGradeLevel != null) {
                                    _updateKDSName();
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // KDS Adı
              TextField(
                controller: _nameController,
                enabled: !isAutoFormat,
                decoration: InputDecoration(
                  labelText: 'KDS Adı',
                  helperText:
                      isAutoFormat ? 'Format otomatik uygulanıyor' : null,
                  helperStyle:
                      TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isAutoFormat ? Colors.grey[100] : Colors.grey[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),

              // Soru sayısı girişi
              TextField(
                controller: _questionCountController,
                decoration: InputDecoration(
                  labelText: 'Çalışma Soru Sayısı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int? count = int.tryParse(value);
                  if (count != null && count > 0) {
                    _updateAnswersheetSize(count);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Answersheet giriş alanı
              if (_questionCount > 0) ...[
                ElevatedButton.icon(
                  onPressed: _showAnswersheetDialog,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    _hasAnyAnswer()
                        ? 'Cevap Anahtarını Düzenle'
                        : 'Cevap Anahtarı Oluştur',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // KDS Image Selector
              BlocBuilder<KDSBloc, KDSState>(
                builder: (context, state) {
                  return KDSImageSelector(
                    kdsId: state.selectedKDS?.id,
                    initialImages: state.kdsImages,
                    onImagesSelected: _handleImagesSelected,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Butonlar
              BlocBuilder<KDSBloc, KDSState>(
                builder: (context, state) {
                  final selectedKDS = state.selectedKDS;

                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: selectedKDS == null
                                  ? [
                                      Colors.deepPurple.shade500,
                                      Colors.deepPurple.shade700
                                    ]
                                  : [
                                      Colors.orange.shade400,
                                      Colors.orange.shade600
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: selectedKDS == null
                                    ? Colors.deepPurple.withOpacity(0.3)
                                    : Colors.orange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _saveKDS,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      selectedKDS == null
                                          ? Icons.add_circle_outline
                                          : Icons.update_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      selectedKDS == null ? 'Ekle' : 'Güncelle',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (selectedKDS != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmDeleteKDS(selectedKDS.id!),
                            icon: const Icon(Icons.delete, size: 20),
                            label: const Text('Sil',
                                style: TextStyle(fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // KDS Listesi
              Expanded(
                child: BlocBuilder<KDSBloc, KDSState>(
                  builder: (context, state) {
                    if (state is KDSLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is KDSListLoaded ||
                        state is KDSSelected ||
                        state is KDSOperationSuccess) {
                      final kdsList = state.kdsList;
                      final selectedKDS = state.selectedKDS;

                      if (kdsList.isEmpty) {
                        return Center(
                          child: Text(
                            'Henüz KDS bulunmamaktadır.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: kdsList.length,
                        itemBuilder: (context, index) {
                          final kds = kdsList[index];
                          final isSelected = selectedKDS?.id == kds.id;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isSelected
                                  ? BorderSide(
                                      color: Colors.deepPurpleAccent, width: 2)
                                  : BorderSide.none,
                            ),
                            color: isSelected
                                ? Colors.deepPurple.shade50
                                : Colors.white,
                            elevation: isSelected ? 8 : 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                kds.kdsName,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Soru Sayısı: ${kds.questionCount}'),
                                  if (kds.answersheet != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green.shade600,
                                              size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Cevap Anahtarı Mevcut',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () => isSelected
                                  ? context.read<KDSBloc>().add(SelectKDS(null))
                                  : context.read<KDSBloc>().add(SelectKDS(kds)),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.deepPurpleAccent)
                                  : null,
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('KDS listesi yüklenemedi.'),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _extractUnitNumber(String unitName) {
    final RegExp regExp = RegExp(r'(\d+)');
    final match = regExp.firstMatch(unitName);
    if (match != null) {
      return match.group(1);
    }
    return null;
  }
}
