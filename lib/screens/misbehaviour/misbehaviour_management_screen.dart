import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/misbehaviour_model.dart';
import '../../api.dart/misbehaviorApi.dart';
import '../../widgets/misbehaviour/misbehaviour_stats_bar.dart';
import '../../widgets/misbehaviour/search_and_add_misbehaviour_card.dart';
import '../../widgets/misbehaviour/misbehaviour_list_view.dart';

class MisbehaviourManagementScreen extends StatefulWidget {
  const MisbehaviourManagementScreen({super.key});

  @override
  State<MisbehaviourManagementScreen> createState() => _MisbehaviourManagementScreenState();
}

class _MisbehaviourManagementScreenState extends State<MisbehaviourManagementScreen> {
  final MisbehaviourApiService apiService =
      MisbehaviourApiService(baseUrl: 'http://localhost:3000');
  final TextEditingController _misbehaviourController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<Misbehaviour> misbehaviours = [];
  List<Misbehaviour> filteredMisbehaviours = [];
  Misbehaviour? selectedMisbehaviour;
  String searchTerm = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMisbehaviours();
  }

  @override
  void dispose() {
    _misbehaviourController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchMisbehaviours() async {
    setState(() => _isLoading = true);
    try {
      final data = await apiService.getAllMisbehaviours();
      setState(() {
        misbehaviours = data;
        filteredMisbehaviours = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage("Yaramazlık listesi yüklenirken hata oluştu: $e");
    }
  }

  void _filterMisbehaviours(String query) {
    setState(() {
      searchTerm = query;
      if (query.isEmpty) {
        filteredMisbehaviours = misbehaviours;
      } else {
        filteredMisbehaviours = misbehaviours
            .where((m) => m.yaramazlikAdi.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _addMisbehaviour() async {
    if (_misbehaviourController.text.trim().isEmpty) {
      _showErrorMessage('Yaramazlık adı boş olamaz');
      return;
    }

    try {
      final newMisbehaviour = Misbehaviour(
        yaramazlikAdi: _misbehaviourController.text.trim(),
      );
      await apiService.addMisbehaviour(newMisbehaviour);
      _misbehaviourController.clear();
      await _fetchMisbehaviours();
      _showSuccessMessage('Yaramazlık başarıyla eklendi');
    } catch (e) {
      _showErrorMessage("Yaramazlık eklenirken hata oluştu: $e");
    }
  }

  Future<void> _updateMisbehaviour() async {
    if (selectedMisbehaviour == null) return;
    if (_misbehaviourController.text.trim().isEmpty) {
      _showErrorMessage('Yaramazlık adı boş olamaz');
      return;
    }

    try {
      final updatedMisbehaviour = Misbehaviour(
        yaramazlikAdi: _misbehaviourController.text.trim(),
      );

      await apiService.updateMisbehaviour(
          selectedMisbehaviour!.id!, updatedMisbehaviour);
      _showSuccessMessage('Yaramazlık başarıyla güncellendi');
      _clearSelection();
      await _fetchMisbehaviours();
    } catch (e) {
      _showErrorMessage("Yaramazlık güncellenirken hata oluştu: $e");
    }
  }

  Future<void> _deleteMisbehaviour(int id) async {
    final result = await _showDeleteConfirmation();
    if (result != true) return;

    try {
      await apiService.deleteMisbehaviour(id);
      _clearSelection();
      await _fetchMisbehaviours();
      _showSuccessMessage('Yaramazlık başarıyla silindi');
    } catch (e) {
      _showErrorMessage("Yaramazlık silinirken hata oluştu: $e");
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text("Silme Onayı"),
            ],
          ),
          content: const Text(
            "Bu yaramazlık kaydını silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "İptal",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Sil",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onMisbehaviourSelect(Misbehaviour misbehaviour) {
    setState(() {
      if (selectedMisbehaviour?.id == misbehaviour.id) {
        _clearSelection();
      } else {
        selectedMisbehaviour = misbehaviour;
        _misbehaviourController.text = misbehaviour.yaramazlikAdi;
      }
    });
  }

  void _onMisbehaviourEdit(Misbehaviour misbehaviour) {
    setState(() {
      selectedMisbehaviour = misbehaviour;
      _misbehaviourController.text = misbehaviour.yaramazlikAdi;
    });
    _focusNode.requestFocus();
  }

  void _clearSelection() {
    setState(() {
      selectedMisbehaviour = null;
      _misbehaviourController.clear();
    });
  }

  void _onSearch() {
    _filterMisbehaviours(_misbehaviourController.text);
  }

  void _onAdd() {
    if (selectedMisbehaviour != null) {
      _updateMisbehaviour();
    } else {
      _addMisbehaviour();
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;
    
    return Material(
      color: AppColors.background,
      child: Column(
        children: [
          // Stats Bar
          MisbehaviourStatsBar(misbehaviourCount: misbehaviours.length),
          
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.05),
                      AppColors.secondary.withOpacity(0.05),
                      AppColors.accent.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(18.5),
                    ),
                    child: isWideScreen
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Form Section
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(
                                      selectedMisbehaviour != null ? 'Yaramazlık Düzenle' : 'Yeni Yaramazlık Ekle',
                                      selectedMisbehaviour != null ? Icons.edit : Icons.add_circle_outline,
                                    ),
                                    const SizedBox(height: 20),
                                    SearchAndAddMisbehaviourCard(
                                      controller: _misbehaviourController,
                                      onSearch: _onSearch,
                                      onAdd: _onAdd,
                                      focusNode: _focusNode,
                                      isEditing: selectedMisbehaviour != null,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Vertical separator
                              Container(
                                width: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.border.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              
                              // List Section
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(
                                      'Yaramazlık Listesi',
                                      Icons.list_alt,
                                    ),
                                    const SizedBox(height: 20),
                                    Expanded(
                                      child: _isLoading
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                              ),
                                            )
                                          : MisbehaviourListView(
                                              misbehaviours: filteredMisbehaviours,
                                              selectedMisbehaviour: selectedMisbehaviour,
                                              onSelect: _onMisbehaviourSelect,
                                              onEdit: _onMisbehaviourEdit,
                                              onDelete: _deleteMisbehaviour,
                                              searchTerm: searchTerm,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Form Section
                              _buildSectionHeader(
                                selectedMisbehaviour != null ? 'Yaramazlık Düzenle' : 'Yeni Yaramazlık Ekle',
                                selectedMisbehaviour != null ? Icons.edit : Icons.add_circle_outline,
                              ),
                              const SizedBox(height: 20),
                              SearchAndAddMisbehaviourCard(
                                controller: _misbehaviourController,
                                onSearch: _onSearch,
                                onAdd: _onAdd,
                                focusNode: _focusNode,
                                isEditing: selectedMisbehaviour != null,
                              ),
                              
                              // Horizontal separator
                              Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.border.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              
                              // List Section
                              _buildSectionHeader(
                                'Yaramazlık Listesi',
                                Icons.list_alt,
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                        ),
                                      )
                                    : MisbehaviourListView(
                                        misbehaviours: filteredMisbehaviours,
                                        selectedMisbehaviour: selectedMisbehaviour,
                                        onSelect: _onMisbehaviourSelect,
                                        onEdit: _onMisbehaviourEdit,
                                        onDelete: _deleteMisbehaviour,
                                        searchTerm: searchTerm,
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
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                selectedMisbehaviour != null 
                    ? 'Seçili yaramazlığı düzenleyin'
                    : 'Yeni bir yaramazlık türü tanımlayın',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (selectedMisbehaviour != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Düzenleniyor',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}