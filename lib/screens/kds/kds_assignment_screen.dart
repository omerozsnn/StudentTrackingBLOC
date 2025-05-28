import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds_class/kds_class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds_class/kds_class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds_class/kds_class_state.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/kds_model.dart';
import 'package:ogrenci_takip_sistemi/models/kds_class_model.dart';
import 'package:ogrenci_takip_sistemi/screens/kds/kd_add_screen.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/loading_indicator.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/error_banner.dart';
import 'package:ogrenci_takip_sistemi/widgets/kds/kds_assignment_option_card.dart';
import 'package:ogrenci_takip_sistemi/widgets/kds/assigned_kds_list.dart';

class KdsAssignmentScreen extends StatefulWidget {
  const KdsAssignmentScreen({Key? key}) : super(key: key);

  @override
  _KdsAssignmentScreenState createState() => _KdsAssignmentScreenState();
}

class _KdsAssignmentScreenState extends State<KdsAssignmentScreen> {
  String? selectedClassLevel;
  final List<String> classLevels = ["5", "6", "7", "8"];
  String? selectedClass;

  String selectedOption = 'level'; // level, class, multiple
  bool isClassLevelSelected = true;
  List<int> selectedKdsIds = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Sınıfları yükle
    context.read<ClassBloc>().add(LoadClassesForDropdown());

    // KDS'leri yükle
    context.read<KDSBloc>().add(LoadKDSList());
  }

  void _onClassChanged(String? newValue) {
    if (newValue == null) return;

    setState(() {
      selectedClass = newValue;
    });

    // Seçilen sınıfa atanmış KDS'leri yükle
    _loadAssignedKds(newValue);
  }

  void _loadAssignedKds(String className) {
    final classState = context.read<ClassBloc>().state;
    if (classState is ClassesLoaded) {
      // Sınıf adından ID'yi bul
      final selectedClassObj = classState.classes.firstWhere(
        (c) => c.sinifAdi == className,
        orElse: () => Classes(id: -1, sinifAdi: ''),
      );

      if (selectedClassObj.id != -1) {
        // KDS atamalarını yükle
        context.read<KdsClassBloc>().add(LoadKdsByClass(selectedClassObj.id));
      }
    }
  }

  // KDS ID'sine göre seçimi değiştir (çoklu seçim için)
  void _toggleKdsSelection(int kdsId) {
    setState(() {
      if (selectedKdsIds.contains(kdsId)) {
        selectedKdsIds.remove(kdsId);
      } else {
        selectedKdsIds.add(kdsId);
      }
    });
  }

  // KDS atama yöntemi kart oluşturma
  Widget _buildAssignmentOptionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KDS Atama Yöntemi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildOptionChip('Sınıf Seviyesine Göre', 'level'),
                _buildOptionChip('Belirli Sınıfa Göre', 'class'),
                _buildOptionChip('Toplu KDS Atama', 'multiple'),
              ],
            ),
            const SizedBox(height: 16),
            // Toplu KDS atama seçeneği için ek seçimler
            if (selectedOption == 'multiple') _buildMultipleAssignmentOptions(),
            const SizedBox(height: 16),
            // Sınıf seviyesi veya sınıf seçimi
            _buildClassSelectionWidget(),
            const SizedBox(height: 16),
            // KDS seçimi
            _buildKdsSelectionWidget(),
          ],
        ),
      ),
    );
  }

  // Atama butonu
  Widget _buildAssignButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleAssignment,
        icon: Icon(
          selectedOption == 'multiple' ? Icons.library_add : Icons.add,
          size: 20,
          color: Colors.white,
        ),
        label: Text(
          selectedOption == 'multiple'
              ? "Seçili KDS'leri Ata (${selectedKdsIds.length})"
              : selectedOption == 'level'
                  ? "Sınıf Seviyesine KDS Ata"
                  : "Belirli Sınıfa KDS Ata",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // Toplu KDS atama seçenekleri
  Widget _buildMultipleAssignmentOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          RadioListTile<bool>(
            title: const Text('Sınıf Seviyesine Göre'),
            value: true,
            groupValue: isClassLevelSelected,
            onChanged: (bool? value) {
              setState(() {
                isClassLevelSelected = value!;
                selectedClass = null;
                selectedClassLevel = null;
                selectedKdsIds.clear();
              });
            },
          ),
          RadioListTile<bool>(
            title: const Text('Belirli Sınıfa Göre'),
            value: false,
            groupValue: isClassLevelSelected,
            onChanged: (bool? value) {
              setState(() {
                isClassLevelSelected = value!;
                selectedClass = null;
                selectedClassLevel = null;
                selectedKdsIds.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  // Sınıf seviyesi veya sınıf seçimi widget'ı
  Widget _buildClassSelectionWidget() {
    if (selectedOption == 'level' ||
        (selectedOption == 'multiple' && isClassLevelSelected)) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Sınıf Seviyesi',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        value: selectedClassLevel,
        onChanged: (String? newValue) {
          setState(() {
            selectedClassLevel = newValue;
            selectedKdsIds.clear();
          });
        },
        items: classLevels.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text('$value. Sınıf'),
          );
        }).toList(),
      );
    } else {
      return BlocBuilder<ClassBloc, ClassState>(
        builder: (context, state) {
          if (state is ClassLoading) {
            return const LoadingIndicator();
          } else if (state is ClassesLoaded) {
            return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Sınıf',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              value: selectedClass,
              onChanged: _onClassChanged,
              items: state.classes.map<DropdownMenuItem<String>>((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem.sinifAdi,
                  child: Text(classItem.sinifAdi),
                );
              }).toList(),
            );
          } else if (state is ClassError) {
            return ErrorBanner(message: state.message);
          }
          return const SizedBox();
        },
      );
    }
  }

  // KDS seçimi widget'ı (tekli veya çoklu)
  Widget _buildKdsSelectionWidget() {
    return BlocBuilder<KDSBloc, KDSState>(
      builder: (context, state) {
        if (state is KDSLoading) {
          return const LoadingIndicator();
        } else if (state is KDSListLoaded || state is KDSSelected) {
          final kdsList = state.kdsList;

          // Sınıf seviyesine göre filtreleme yap
          final filteredKdsList = _getFilteredKdsList(kdsList);

          if (selectedOption != 'multiple') {
            // Tekli KDS seçimi dropdown
            return DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'KDS',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              value: selectedKdsIds.isNotEmpty ? selectedKdsIds.first : null,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedKdsIds = [newValue];
                  });
                }
              },
              items: filteredKdsList.map<DropdownMenuItem<int>>((kds) {
                return DropdownMenuItem<int>(
                  value: kds.id,
                  child: Text(kds.kdsName),
                );
              }).toList(),
            );
          } else {
            // Çoklu KDS seçimi listesi
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KDS Seçimi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: filteredKdsList.isEmpty
                      ? Center(
                          child: Text(
                            'Bu sınıf düzeyi için KDS bulunamadı',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredKdsList.length,
                          itemBuilder: (context, index) {
                            final kds = filteredKdsList[index];
                            return _buildKdsSelectionCard(kds);
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedKdsIds =
                                filteredKdsList.map((kds) => kds.id!).toList();
                          });
                        },
                        icon: const Icon(Icons.select_all, size: 20),
                        label: const Text('Tümünü Seç'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedKdsIds.clear();
                          });
                        },
                        icon: const Icon(Icons.deselect, size: 20),
                        label: const Text('Temizle'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        } else if (state is KDSError) {
          return ErrorBanner(message: state.message);
        }
        return const SizedBox();
      },
    );
  }

  // Atama işlemlerini yöneten fonksiyon
  void _handleAssignment() {
    if (selectedKdsIds.isEmpty) {
      UIHelpers.showErrorMessage(context, 'Lütfen en az bir KDS seçin');
      return;
    }

    final classState = context.read<ClassBloc>().state;
    if (selectedOption == 'multiple') {
      _handleMultipleAssignment(classState);
    } else if (selectedOption == 'level') {
      _handleLevelAssignment();
    } else {
      _handleClassAssignment(classState);
    }
  }

  // Çoklu KDS atama işlemi
  void _handleMultipleAssignment(ClassState classState) {
    if (isClassLevelSelected) {
      if (selectedClassLevel == null) {
        UIHelpers.showErrorMessage(context, 'Lütfen bir sınıf seviyesi seçin');
        return;
      }

      context.read<KdsClassBloc>().add(
            AssignMultipleKdsToClasses(
              kdsIds: selectedKdsIds,
              classLevel: selectedClassLevel,
              isClassLevelSelected: true,
            ),
          );
    } else {
      if (selectedClass == null) {
        UIHelpers.showErrorMessage(context, 'Lütfen bir sınıf seçin');
        return;
      }

      if (classState is ClassesLoaded) {
        final selectedClassObj = classState.classes.firstWhere(
          (c) => c.sinifAdi == selectedClass,
          orElse: () => Classes(id: -1, sinifAdi: ''),
        );

        if (selectedClassObj.id != -1) {
          context.read<KdsClassBloc>().add(
                AssignMultipleKdsToClasses(
                  kdsIds: selectedKdsIds,
                  classId: selectedClassObj.id,
                  isClassLevelSelected: false,
                ),
              );
        }
      }
    }
  }

  // Sınıf seviyesine KDS atama
  void _handleLevelAssignment() {
    if (selectedClassLevel == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir sınıf seviyesi seçin');
      return;
    }

    if (selectedKdsIds.isEmpty) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir KDS seçin');
      return;
    }

    final kdsId = selectedKdsIds.first;

    if (selectedClassLevel == "6") {
      context.read<KdsClassBloc>().add(AssignKdsToSixthGrade(kdsId));
    } else if (selectedClassLevel == "7") {
      context.read<KdsClassBloc>().add(AssignKdsToSeventhGrade(kdsId));
    } else if (selectedClassLevel == "8") {
      context.read<KdsClassBloc>().add(AssignKdsToEighthGrade(kdsId));
    } else if (selectedClassLevel == "5") {
      UIHelpers.showErrorMessage(
        context,
        '5. sınıflar için KDS atama fonksiyonu tanımlanmamış.',
      );
    }
  }

  // Belirli sınıfa KDS atama
  void _handleClassAssignment(ClassState classState) {
    if (selectedClass == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir sınıf seçin');
      return;
    }

    if (selectedKdsIds.isEmpty) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir KDS seçin');
      return;
    }

    if (classState is ClassesLoaded) {
      final selectedClassObj = classState.classes.firstWhere(
        (c) => c.sinifAdi == selectedClass,
        orElse: () => Classes(id: -1, sinifAdi: ''),
      );

      if (selectedClassObj.id != -1) {
        context.read<KdsClassBloc>().add(
              AssignKdsToClass(
                selectedKdsIds.first,
                selectedClassObj.id,
              ),
            );
      }
    }
  }

  // KDS'leri filtrele (sınıf seviyesine göre)
  List<KDS> _getFilteredKdsList(List<KDS> kdsList) {
    if (selectedOption == 'multiple') {
      if (isClassLevelSelected) {
        // Sınıf seviyesine göre filtreleme
        if (selectedClassLevel == null) return kdsList;
        return kdsList.where((kds) {
          String kdsName = kds.kdsName;
          return kdsName.startsWith('$selectedClassLevel-');
        }).toList();
      } else {
        // Belirli sınıfa göre filtreleme
        if (selectedClass == null) return kdsList;

        // Sınıf adından seviyeyi çıkar (örn: "6 A" -> "6")
        String classLevel = selectedClass!.split(' ')[0];

        return kdsList.where((kds) {
          String kdsName = kds.kdsName;
          return kdsName.startsWith('$classLevel-');
        }).toList();
      }
    } else {
      // Tek KDS seçimi için filtreleme
      if (selectedClassLevel == null) return kdsList;
      return kdsList.where((kds) {
        String kdsName = kds.kdsName;
        return kdsName.startsWith('$selectedClassLevel-');
      }).toList();
    }
  }

  // KDS seçim kartı
  Widget _buildKdsSelectionCard(KDS kds) {
    bool isSelected = selectedKdsIds.contains(kds.id);

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.teal : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => _toggleKdsSelection(kds.id!),
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? Colors.teal : Colors.grey,
        ),
        title: Text(
          kds.kdsName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('Soru Sayısı: ${kds.questionCount}'),
      ),
    );
  }

  // Seçenek chip'i
  Widget _buildOptionChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedOption == value,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            selectedOption = value;
            if (value != 'multiple') {
              selectedKdsIds.clear();
            }

            // Eğer 'class' seçeneği seçildiyse ve bir sınıf zaten seçiliyse atanmış KDS'leri yükle
            if (value == 'class' && selectedClass != null) {
              _loadAssignedKds(selectedClass!);
            }
          }
        });
      },
      selectedColor: Colors.teal.shade100,
      backgroundColor: Colors.grey.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KDS Atama"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'KDS Ekle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KDSAddScreen(),
                ),
              ).then((_) {
                // KDS ekranından geri döndüğünde KDS listesini yenile
                context.read<KDSBloc>().add(LoadKDSList());
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadInitialData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<KdsClassBloc, KdsClassState>(
        listener: (context, state) {
          if (state is KdsClassLoading) {
            // Yükleme durumunda bir şey yapma (widgetlar zaten yükleme durumunu gösterecek)
          } else if (state is KdsClassOperationSuccess) {
            UIHelpers.showSuccessMessage(context, state.message);

            // İşlem başarılı olduysa seçimleri sıfırla
            setState(() {
              selectedKdsIds.clear();
            });

            // Belirli bir sınıfa atama yapıldıysa, o sınıfa atanmış KDS'leri yeniden yükle
            if (selectedOption == 'class' && selectedClass != null) {
              _loadAssignedKds(selectedClass!);
            }
          } else if (state is KdsClassError) {
            UIHelpers.showErrorMessage(context, state.message);
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAssignmentOptionCard(),
                const SizedBox(height: 16),
                if (selectedOption == 'class' && selectedClass != null)
                  BlocBuilder<KdsClassBloc, KdsClassState>(
                    builder: (context, state) {
                      if (state is KdsClassLoading) {
                        return const LoadingIndicator();
                      } else if (state is KdsAssignedListLoaded ||
                          state is KdsClassOperationSuccess) {
                        return AssignedKdsList(
                          className: selectedClass!,
                          assignedKdsList: state.assignedKdsList,
                          onDeleteKds: (kdsId, classId) {
                            context
                                .read<KdsClassBloc>()
                                .add(DeleteKdsFromClass(kdsId, classId));
                          },
                          onRefresh: () {
                            if (selectedClass != null) {
                              _loadAssignedKds(selectedClass!);
                            }
                          },
                        );
                      } else if (state is KdsClassError) {
                        return ErrorBanner(message: state.message);
                      }
                      return const SizedBox();
                    },
                  ),
                const SizedBox(height: 16),
                _buildAssignButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
