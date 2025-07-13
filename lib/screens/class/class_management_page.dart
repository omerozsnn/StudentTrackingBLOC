import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';
import '../../blocs/class/class_bloc.dart';
import '../../blocs/class/class_event.dart';
import '../../blocs/class/class_state.dart';
import '../../models/classes_model.dart';
import '../../widgets/class/search_and_add_class_card.dart';
import '../../widgets/class/class_list_view.dart';
import '../../widgets/class/class_stats_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class ClassManagementPage extends StatefulWidget {
  const ClassManagementPage({super.key});

  @override
  _ClassManagementPageState createState() => _ClassManagementPageState();
}

class _ClassManagementPageState extends State<ClassManagementPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    context.read<ClassBloc>().add(LoadClassesWithPagination(page: 1, limit: 100)); // Load all for now
    _controller.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    // Only filter if not in edit mode
    if (context.read<ClassBloc>().state.selectedClass == null) {
      setState(() {
        _searchTerm = _controller.text;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  void _addClass() {
    if (_controller.text.isNotEmpty) {
      final newClass = Classes(
        id: 0, 
        sinifAdi: _controller.text,
      );
      context.read<ClassBloc>().add(AddClass(newClass));
      _controller.clear();
      _focusNode.unfocus();
    } else {
      _showSnackBar('Sınıf adı zorunludur!', isError: true);
    }
  }

  void _updateClass() {
    final classBloc = context.read<ClassBloc>();
    final selectedClass = classBloc.state.selectedClass;
    
    if (selectedClass != null && _controller.text.isNotEmpty) {
      final updatedClass = selectedClass.copyWith(
        sinifAdi: _controller.text,
      );
      classBloc.add(UpdateClass(updatedClass));
      classBloc.add(const SelectClass(null));
      _controller.clear();
      _focusNode.unfocus();
    } else {
      _showSnackBar('Sınıf seçimi ve sınıf adı zorunludur!', isError: true);
    }
  }

  void _removeClass(int classId) {
    context.read<ClassBloc>().add(DeleteClass(classId));
     _controller.clear();
     context.read<ClassBloc>().add(const SelectClass(null));
  }

  void _onSelectClass(Classes sinif) {
    final classBloc = context.read<ClassBloc>();
    if (classBloc.state.selectedClass?.id == sinif.id) {
      // Deselecting
      classBloc.add(const SelectClass(null));
      _controller.clear();
    } else {
      // Selecting for edit
      _controller.removeListener(_onSearchChanged);
      classBloc.add(SelectClass(sinif));
      _controller.text = sinif.sinifAdi;
      setState(() {
        _searchTerm = null;
      });
      _controller.addListener(_onSearchChanged);
    }
  }

  void _onEditClass(Classes sinif) {
    _onSelectClass(sinif);
    _focusNode.requestFocus();
  }

  Future<void> _uploadClassExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      context.read<ClassBloc>().add(UploadClassExcel(file));
    } else {
      _showSnackBar('Dosya seçilmedi', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClassBloc, ClassState>(
        listener: (context, state) {
          if (state is ClassError) {
            _showSnackBar(state.message, isError: true);
          } else if (state is ClassOperationSuccess) {
            _showSnackBar(state.message);
          }
        },
        builder: (context, state) {
          final classes = state.classes;
          final isLoading = state is ClassLoading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(isLoading),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildUnifiedCard(state, classes, isLoading),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isLoading) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Text('🏫', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        const Text(
          'Sınıf Yönetimi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          icon: Image.asset('assets/icons/sheet.png', height: 24, width: 24),
          label: const Text("Excel'e Aktar"),
          onPressed: isLoading ? null : _uploadClassExcel,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildUnifiedCard(ClassState state, List<Classes> classes, bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3498DB), 
            Color(0xFF1ABC9C), 
            Color(0xFFF39C12), 
            Color(0xFFE74C3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ]
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: SearchAndAddClassCard(
                controller: _controller,
                focusNode: _focusNode,
                onSearch: () {
                  _focusNode.unfocus();
                },
                onAdd: state.selectedClass == null ? _addClass : _updateClass,
              ),
            ),
            const Divider(height: 1, indent: 24, endIndent: 24),
            Expanded(
              child: isLoading && classes.isEmpty
                  ? const LoadingIndicator()
                  : ClassListView(
                      classes: classes,
                      selectedClass: state.selectedClass,
                      onSelect: _onSelectClass,
                      onEdit: _onEditClass,
                      onDelete: _removeClass,
                      searchTerm: _searchTerm,
                    ),
            ),
            ClassStatsBar(
              classCount: classes.length,
              studentCount: 0, // Placeholder
            )
          ],
        ),
      ),
    );
  }
} 