import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/class/class_bloc.dart';
import '../../blocs/class/class_event.dart';
import '../../blocs/class/class_state.dart';
import '../../models/classes_model.dart';
import '../../widgets/class/class_form.dart';
import '../../widgets/class/class_list_item.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

class ClassAddPage extends StatefulWidget {
  const ClassAddPage({super.key});

  @override
  _ClassAddPageState createState() => _ClassAddPageState();
}

class _ClassAddPageState extends State<ClassAddPage> {
  final TextEditingController _sinifAdiController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialClasses();
    });
    
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _sinifAdiController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreClasses();
    }
  }
  
  void _loadInitialClasses() {
    context.read<ClassBloc>().add(LoadClassesWithPagination(page: 1, limit: _pageSize));
  }
  
  void _loadMoreClasses() {
    setState(() {
      _isLoadingMore = true;
    });
    
    _currentPage++;
    context.read<ClassBloc>().add(LoadClassesWithPagination(page: _currentPage, limit: _pageSize));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addClass() async {
    if (_sinifAdiController.text.isNotEmpty) {
      // Create a new class with a placeholder ID (will be assigned by backend)
      final newClass = Classes(
        id: 0, // This will be assigned by backend
        sinifAdi: _sinifAdiController.text,
      );
      context.read<ClassBloc>().add(AddClass(newClass));
      _sinifAdiController.clear();
    } else {
      _showSnackBar('Sınıf adı zorunludur!');
    }
  }

  Future<void> _removeClass() async {
    final classBloc = context.read<ClassBloc>();
    final selectedClass = classBloc.selectedClass;
    
    if (selectedClass != null) {
      classBloc.add(DeleteClass(selectedClass.id));
      _sinifAdiController.clear();
    } else {
      _showSnackBar('Lütfen silmek için bir sınıf seçin');
    }
  }

  Future<void> _updateClass() async {
    final classBloc = context.read<ClassBloc>();
    final selectedClass = classBloc.selectedClass;
    
    if (selectedClass != null && _sinifAdiController.text.isNotEmpty) {
      final updatedClass = selectedClass.copyWith(
        sinifAdi: _sinifAdiController.text,
      );
      classBloc.add(UpdateClass(updatedClass));
      _sinifAdiController.clear();
    } else {
      _showSnackBar('Sınıf seçimi ve sınıf adı zorunludur!');
    }
  }

  void _onSinifTap(Classes sinif) {
    final classBloc = context.read<ClassBloc>();
    if (classBloc.selectedClass?.id == sinif.id) {
      classBloc.add(const SelectClass(null));
      _sinifAdiController.clear();
    } else {
      classBloc.add(SelectClass(sinif));
      _sinifAdiController.text = sinif.sinifAdi;
    }
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
      _showSnackBar('Dosya seçilmedi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Sınıf Ekleme', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ClassBloc, ClassState>(
        listener: (context, state) {
          if (state is ClassError) {
            _showSnackBar(state.message);
          } else if (state is ClassOperationSuccess) {
            _showSnackBar(state.message);
          } else if (state is ClassesLoaded) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Widget
                ClassForm(
                  controller: _sinifAdiController,
                  onAddClass: _addClass,
                  onUpdateClass: _updateClass,
                  onDeleteClass: _removeClass,
                ),
                const SizedBox(height: 20),
                // List Widget
                Expanded(
                  child: _buildClassList(state),
                ),
                const SizedBox(height: 20),
                // Excel Upload Button
                CustomButton(
                  text: 'Excel ile Sınıf Ekle',
                  icon: Icons.upload_file,
                  onPressed: state is ClassLoading ? null : _uploadClassExcel,
                  backgroundColor: Colors.orange,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassList(ClassState state) {
    if (state is ClassLoading && context.read<ClassBloc>().classes.isEmpty) {
      return const LoadingIndicator();
    }

    if (state is ClassError && state.classes.isEmpty) {
      return Center(child: Text(state.message));
    }

    final classes = context.read<ClassBloc>().classes;
    
    if (classes.isEmpty) {
      return Center(child: Text('Henüz sınıf bulunmamaktadır.'));
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: classes.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == classes.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final sinif = classes[index];
            final isSelected = state.selectedClass?.id == sinif.id;

            return ClassListItem(
              sinif: sinif,
              isSelected: isSelected,
              onTap: () => _onSinifTap(sinif),
            );
          },
        ),
        if (state is ClassLoading && context.read<ClassBloc>().classes.isNotEmpty && !_isLoadingMore)
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
} 