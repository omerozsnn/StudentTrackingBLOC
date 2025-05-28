import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/student_model.dart';
import '../../blocs/student/student_bloc.dart';
import '../../blocs/student/student_state.dart';
import '../../utils/ui_helpers.dart';

class StudentSelector extends StatefulWidget {
  final List<Student> students;
  final List<int> selectedStudentIds;
  final Function(List<int>) onSelectionChanged;

  const StudentSelector({
    Key? key,
    required this.students,
    required this.selectedStudentIds,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<StudentSelector> createState() => _StudentSelectorState();
}

class _StudentSelectorState extends State<StudentSelector> {
  bool _selectAll = false;
  List<int> _selectedStudentIds = [];
  TextEditingController _searchController = TextEditingController();
  List<Student> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _selectedStudentIds = List.from(widget.selectedStudentIds);
    _filteredStudents = List.from(widget.students);
    _updateSelectAllState();
  }

  @override
  void didUpdateWidget(StudentSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students ||
        oldWidget.selectedStudentIds != widget.selectedStudentIds) {
      _selectedStudentIds = List.from(widget.selectedStudentIds);
      _filteredStudents = List.from(widget.students);
      _updateSelectAllState();
    }
  }

  void _updateSelectAllState() {
    setState(() {
      _selectAll = _selectedStudentIds.length == widget.students.length &&
          widget.students.isNotEmpty;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectAll) {
        _selectedStudentIds.clear();
      } else {
        _selectedStudentIds =
            widget.students.map((student) => student.id).toList();
      }
      _selectAll = !_selectAll;
      widget.onSelectionChanged(_selectedStudentIds);
    });
  }

  void _toggleStudentSelection(Student student) {
    setState(() {
      if (_selectedStudentIds.contains(student.id)) {
        _selectedStudentIds.remove(student.id);
      } else {
        _selectedStudentIds.add(student.id);
      }
      _updateSelectAllState();
      widget.onSelectionChanged(_selectedStudentIds);
    });
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = List.from(widget.students);
      } else {
        _filteredStudents = widget.students
            .where((student) =>
                student.adSoyad.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Öğrenci Seçin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Arama kutusu
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Öğrenci Ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterStudents,
            ),

            const SizedBox(height: 10),

            // Hepsini seç düğmesi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedStudentIds.length} öğrenci seçildi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                TextButton.icon(
                  icon: Icon(_selectAll
                      ? Icons.check_box
                      : Icons.check_box_outline_blank),
                  label: Text(_selectAll ? 'Hepsini Kaldır' : 'Hepsini Seç'),
                  onPressed: _toggleSelectAll,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Öğrenci listesi
            Expanded(
              child: _filteredStudents.isEmpty
                  ? Center(
                      child: Text(
                        'Öğrenci Bulunamadı',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return CheckboxListTile(
                          title: Text(student.adSoyad),
                          subtitle: Text(
                              'Öğrenci No: ${student.ogrenciNo ?? "Belirtilmemiş"}'),
                          value: _selectedStudentIds.contains(student.id),
                          onChanged: (bool? value) {
                            _toggleStudentSelection(student);
                          },
                          secondary: const Icon(Icons.person),
                          activeColor: Colors.teal,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
