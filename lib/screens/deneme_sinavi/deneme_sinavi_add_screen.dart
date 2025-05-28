import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/api.dart/denemeSınaviApi.dart';
import 'package:ogrenci_takip_sistemi/api.dart/unitsApi.dart' as units_api;
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_state.dart';
import 'package:ogrenci_takip_sistemi/models/deneme_sinavi_model.dart';
import 'package:ogrenci_takip_sistemi/models/units_model.dart';
import 'package:ogrenci_takip_sistemi/screens/deneme_sinavi/deneme_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/exam_assignment/exam_assignment_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/unit/unit_screen.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/error_banner.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/loading_indicator.dart';
import 'package:ogrenci_takip_sistemi/widgets/deneme_sinavi/deneme_sinavi_card.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';

class AddDenemeSinaviScreen extends StatefulWidget {
  const AddDenemeSinaviScreen({super.key});

  @override
  State<AddDenemeSinaviScreen> createState() => _AddDenemeSinaviScreenState();
}

class _AddDenemeSinaviScreenState extends State<AddDenemeSinaviScreen> {
  final units_api.ApiService unitsApi = units_api.ApiService();

  late DenemeSinaviBloc _denemeSinaviBloc;
  List<Unit> uniteList = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _questionCountController =
      TextEditingController();

  String? selectedGradeLevel;
  int? selectedUniteId;
  String? selectedUniteName;
  String? selectedUnitNumber;
  bool isAutoFormat = true;

  final List<String> gradeLevels = ['5', '6', '7', '8'];

  @override
  void initState() {
    super.initState();

    // We'll get the bloc from the provider in the widget tree
    // so we'll assign it in didChangeDependencies

    // Load initial data
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the BLoC from the provider
    _denemeSinaviBloc = BlocProvider.of<DenemeSinaviBloc>(context);

    // Load data if it's the first time
    if (_denemeSinaviBloc.denemeSinavlari.isEmpty) {
      _denemeSinaviBloc.add(LoadDenemeSinavlari());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _questionCountController.dispose();
    // We don't need to close the BLoC since it's provided by a parent widget
    // _denemeSinaviBloc.close();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Load only units - the BLoC data will be loaded in didChangeDependencies
    await _loadUniteList();
  }

  Future<void> _loadUniteList() async {
    try {
      // The API already returns a List<Unit>, so we can use it directly
      final units = await unitsApi.getAllUnits();

      setState(() {
        uniteList = units;
      });
    } catch (error) {
      print('Ünite listesi yüklenemedi: $error');
      if (mounted) {
        UIHelpers.showErrorMessage(
            context, 'Ünite listesi yüklenirken hata oluştu');
      }
    }
  }

  void _parseUnitNumber(String unitName) {
    final RegExp regExp = RegExp(r'(\d+)');
    final match = regExp.firstMatch(unitName);
    if (match != null) {
      setState(() {
        selectedUnitNumber = match.group(1);
      });
    }
  }

  Future<int> _getNextExamNumber() async {
    if (selectedUniteId == null || selectedGradeLevel == null) return 1;

    try {
      var denemeSinavlari = _denemeSinaviBloc.denemeSinavlari;

      var unitExams = denemeSinavlari.where((exam) {
        if (exam.denemeSinaviAdi == null) return false;

        List<String> parts = exam.denemeSinaviAdi!.split('-');
        if (parts.length >= 2) {
          String examGradeLevel = parts[0];
          return exam.uniteId == selectedUniteId &&
              examGradeLevel == selectedGradeLevel &&
              exam.denemeSinaviAdi!.endsWith('.Deneme');
        }
        return false;
      }).toList();

      List<int> existingNumbers = [];
      for (var exam in unitExams) {
        String examName = exam.denemeSinaviAdi!;
        RegExp regExp = RegExp(r'-(\d+)\.Deneme$');
        var match = regExp.firstMatch(examName);
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
      return 1;
    }
  }

  Future<void> _updateExamName() async {
    if (!isAutoFormat ||
        selectedGradeLevel == null ||
        selectedUnitNumber == null) return;

    final nextNumber = await _getNextExamNumber();
    final formattedName =
        '$selectedGradeLevel-$selectedUnitNumber-$nextNumber.Deneme';

    setState(() {
      _nameController.text = formattedName;
    });
  }

  Future<void> _saveDenemeSinavi() async {
    final String name = _nameController.text;
    final int? questionCount = int.tryParse(_questionCountController.text);

    if (name.isEmpty) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir sınav adı girin.');
      return;
    }

    if (questionCount == null) {
      UIHelpers.showErrorMessage(
          context, 'Lütfen geçerli bir soru sayısı girin.');
      return;
    }

    if (selectedUniteId == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir ünite seçin.');
      return;
    }

    final denemeSinavi = DenemeSinavi(
      id: _denemeSinaviBloc.selectedDenemeSinavi?.id,
      denemeSinaviAdi: name,
      soruSayisi: questionCount,
      uniteId: selectedUniteId,
    );

    if (_denemeSinaviBloc.selectedDenemeSinavi == null) {
      _denemeSinaviBloc.add(AddDenemeSinavi(denemeSinavi));
    } else {
      _denemeSinaviBloc.add(UpdateDenemeSinavi(denemeSinavi));
    }

    _clearForm();
  }

  void _confirmDeleteDenemeSinavi(int id) {
    UIHelpers.showConfirmationDialog(
            context: context,
            title: 'Deneme Sınavı Sil',
            content:
                'Bu deneme sınavını silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz.',
            confirmText: 'Sil',
            cancelText: 'İptal')
        .then((confirmed) {
      if (confirmed) {
        _denemeSinaviBloc.add(
            DeleteDenemeSinavi(_denemeSinaviBloc.selectedDenemeSinavi!.id!));
      }
    });
  }

  void _clearForm() {
    _nameController.clear();
    _questionCountController.clear();
    setState(() {
      selectedUniteId = null;
      selectedGradeLevel = null;
      selectedUniteName = null;
      selectedUnitNumber = null;
      if (!isAutoFormat) {
        isAutoFormat = true;
      }
    });

    _denemeSinaviBloc.add(const SelectDenemeSinavi(null));
  }

  void _toggleSelection(DenemeSinavi denemeSinavi) {
    if (_denemeSinaviBloc.selectedDenemeSinavi?.id == denemeSinavi.id) {
      _clearForm();
    } else {
      _denemeSinaviBloc.add(SelectDenemeSinavi(denemeSinavi));

      _nameController.text = denemeSinavi.denemeSinaviAdi ?? '';
      _questionCountController.text = denemeSinavi.soruSayisi?.toString() ?? '';

      setState(() {
        selectedUniteId = denemeSinavi.uniteId;

        // Find the unit name for the selected unit ID
        if (selectedUniteId != null) {
          final unit = uniteList.firstWhere(
            (unit) => unit.id == selectedUniteId,
            orElse: () => Unit(id: null, unitName: ''),
          );

          if (unit.unitName.isNotEmpty) {
            selectedUniteName = unit.unitName;
            _parseUnitNumber(unit.unitName);
          }
        }

        isAutoFormat = false; // Düzenleme modunda otomatik format kapalı
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deneme Sınavı Yönetimi'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          // Ünite Ekleme button
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
                // Refresh unit list when returning
                _loadUniteList();
              });
            },
          ),
          // Deneme Kontrol button
          IconButton(
            icon: const Icon(Icons.assignment_ind),
            tooltip: 'Deneme Atama',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExamAssignmentScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<DenemeSinaviBloc, DenemeSinaviState>(
        listener: (context, state) {
          if (state is DenemeSinaviOperationSuccess) {
            UIHelpers.showSuccessMessage(context, state.message);
          } else if (state is DenemeSinaviError) {
            UIHelpers.showErrorMessage(context, state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Otomatik format switch
                _buildAutoFormatSwitch(),
                const SizedBox(height: 12),

                // Sınıf ve Ünite seçimi
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildGradeLevelDropdown(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _buildUniteDropdown(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Form alanları
                _buildTextField(
                  _nameController,
                  'Deneme Sınavı Adı',
                  enabled: !isAutoFormat,
                  helperText:
                      isAutoFormat ? 'Format otomatik uygulanıyor' : null,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  _questionCountController,
                  'Soru Sayısı',
                  isNumeric: true,
                ),
                const SizedBox(height: 16),

                // Aksiyon butonları
                _buildActionButtons(),
                const SizedBox(height: 16),

                // Liste
                if (state is DenemeSinaviLoading &&
                    _denemeSinaviBloc.denemeSinavlari.isEmpty)
                  const Expanded(
                    child: Center(
                      child: LoadingIndicator(),
                    ),
                  )
                else if (state is DenemeSinaviError &&
                    _denemeSinaviBloc.denemeSinavlari.isEmpty)
                  Expanded(
                    child: Center(
                      child: ErrorBanner(
                        message: state.message,
                        onRetry: () =>
                            _denemeSinaviBloc.add(LoadDenemeSinavlari()),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: _buildDenemeSinaviList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAutoFormatSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 20, color: Colors.deepPurple.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Otomatik Format: ${selectedGradeLevel != null && selectedUnitNumber != null ? "$selectedGradeLevel-$selectedUnitNumber-X.Deneme" : "Sınıf-Ünite-Sıra.Deneme"}',
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
                    selectedUnitNumber != null) {
                  _updateExamName();
                }
              });
            },
            activeColor: Colors.deepPurpleAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeLevelDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text('Sınıf'),
          value: selectedGradeLevel,
          isExpanded: true,
          items: gradeLevels.map<DropdownMenuItem<String>>((String level) {
            return DropdownMenuItem<String>(
              value: level,
              child: Text('$level. Sınıf'),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedGradeLevel = newValue;
              selectedUniteName = null;
              selectedUniteId = null;
              if (isAutoFormat) {
                _updateExamName();
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildUniteDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text('Ünite Seçin'),
          value: selectedUniteName,
          isExpanded: true,
          items: uniteList.map<DropdownMenuItem<String>>((unit) {
            return DropdownMenuItem<String>(
              value: unit.unitName,
              child: Text(unit.unitName.isEmpty ? 'Bilinmiyor' : unit.unitName),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedUniteName = newValue;
              if (newValue != null) {
                final unit = uniteList.firstWhere(
                  (unit) => unit.unitName == newValue,
                  orElse: () => Unit(id: null, unitName: ''),
                );
                if (unit.id != null) {
                  selectedUniteId = unit.id;
                  _parseUnitNumber(newValue);
                  if (isAutoFormat) {
                    _updateExamName();
                  }
                }
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    bool isNumeric = false,
    bool enabled = true,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        helperText: helperText,
        helperStyle: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: TextStyle(
        color: enabled ? Colors.black87 : Colors.grey.shade700,
        fontSize: 14,
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _denemeSinaviBloc.selectedDenemeSinavi == null
                    ? [Colors.deepPurple.shade500, Colors.deepPurple.shade700]
                    : [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _denemeSinaviBloc.selectedDenemeSinavi == null
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
                onTap: _saveDenemeSinavi,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _denemeSinaviBloc.selectedDenemeSinavi == null
                            ? Icons.add_circle_outline
                            : Icons.update_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _denemeSinaviBloc.selectedDenemeSinavi == null
                            ? 'Ekle'
                            : 'Güncelle',
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
        if (_denemeSinaviBloc.selectedDenemeSinavi != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _confirmDeleteDenemeSinavi(
                      _denemeSinaviBloc.selectedDenemeSinavi!.id!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Sil',
                          style: TextStyle(
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
        ],
      ],
    );
  }

  Widget _buildDenemeSinaviList() {
    return BlocBuilder<DenemeSinaviBloc, DenemeSinaviState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: _denemeSinaviBloc.denemeSinavlari.length,
          itemBuilder: (context, index) {
            final denemeSinavi = _denemeSinaviBloc.denemeSinavlari[index];
            final isSelected =
                _denemeSinaviBloc.selectedDenemeSinavi?.id == denemeSinavi.id;

            return DenemeSinaviCard(
              denemeSinavi: denemeSinavi,
              isSelected: isSelected,
              uniteAdi: _getUniteAdi(denemeSinavi.uniteId),
              onTap: () => _toggleSelection(denemeSinavi),
            );
          },
        );
      },
    );
  }

  String _getUniteAdi(int? uniteId) {
    if (uniteId == null) return 'Bilinmiyor';
    final unit = uniteList.firstWhere(
      (unit) => unit.id == uniteId,
      orElse: () => Unit(id: null, unitName: 'Bilinmiyor'),
    );
    return unit.unitName.isEmpty ? 'Bilinmiyor' : unit.unitName;
  }
}
