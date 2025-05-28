import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_state.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'package:ogrenci_takip_sistemi/screens/course/course_class_assign_page.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';

class CourseAddPage extends StatefulWidget {
  const CourseAddPage({super.key});

  @override
  _CourseAddPageState createState() => _CourseAddPageState();
}

class _CourseAddPageState extends State<CourseAddPage> {
  final TextEditingController _controller = TextEditingController();
  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();
    // Load courses when page initializes
    BlocProvider.of<CourseBloc>(context).add(LoadCourses());
  }

  void _onCourseTap(Course course) {
    setState(() {
      if (_selectedCourse != null && _selectedCourse!.id == course.id) {
        _selectedCourse = null;
        _controller.clear();
      } else {
        _selectedCourse = course;
        _controller.text = course.dersAdi;
      }
    });
  }

  void _addCourse() {
    if (_controller.text.isNotEmpty) {
      final newCourse = Course(id: 0, dersAdi: _controller.text);
      BlocProvider.of<CourseBloc>(context).add(AddCourse(newCourse));
      _controller.clear();
    } else {
      UIHelpers.showErrorMessage(context, 'Ders adı zorunludur!');
    }
  }

  void _updateCourse() {
    if (_selectedCourse != null && _controller.text.isNotEmpty) {
      final updatedCourse = Course(id: _selectedCourse!.id, dersAdi: _controller.text);
      BlocProvider.of<CourseBloc>(context).add(UpdateCourse(updatedCourse));
      setState(() {
        _selectedCourse = null;
        _controller.clear();
      });
    } else {
      UIHelpers.showErrorMessage(context, 'Ders adı ve ders seçimi zorunludur!');
    }
  }

  Future<void> _removeCourse() async {
    if (_selectedCourse != null) {
      final confirm = await UIHelpers.showConfirmationDialog(
        context: context,
        title: 'Emin misiniz?',
        content: 'Bu dersi silmek istediğinizden emin misiniz?',
      );

      if (confirm) {
        BlocProvider.of<CourseBloc>(context).add(DeleteCourse(_selectedCourse!.id));
        setState(() {
          _selectedCourse = null;
          _controller.clear();
        });
      }
    } else {
      UIHelpers.showErrorMessage(context, 'Ders seçimi zorunludur!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Ekleme'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          // Ders Atama sayfasına yönlendirme butonu
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: 'Ders Atama',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CourseClassAssignPage(),
                ),
              ).then((_) {
                // Reload courses when returning from CourseAssignPage
                BlocProvider.of<CourseBloc>(context).add(LoadCourses());
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CourseOperationSuccess) {
            UIHelpers.showSuccessMessage(context, state.message);
          } else if (state is CourseError) {
            UIHelpers.showErrorMessage(context, state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ders adı için giriş alanı
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Ders Adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),
                // Ekle, Güncelle ve Sil butonları
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state is CourseLoading
                            ? null
                            : (_selectedCourse == null ? _addCourse : _updateCourse),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedCourse == null
                              ? Colors.deepPurpleAccent
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _selectedCourse == null ? 'Ekle' : 'Güncelle',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_selectedCourse != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state is CourseLoading ? null : _removeCourse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Sil', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Ders listesini gösteren bölüm
                if (state is CourseLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state is CoursesLoaded ? state.courses.length : 0,
                      itemBuilder: (context, index) {
                        if (state is CoursesLoaded) {
                          final course = state.courses[index];
                          final isSelected = _selectedCourse != null && 
                                           course.id == _selectedCourse!.id;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: isSelected
                                  ? BorderSide(color: Colors.deepPurpleAccent, width: 2)
                                  : BorderSide.none,
                            ),
                            color: isSelected 
                                ? Colors.deepPurple.shade50 
                                : Colors.white,
                            elevation: isSelected ? 8 : 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                course.dersAdi,
                                style: TextStyle(
                                  fontWeight: isSelected 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  color: isSelected 
                                      ? Colors.deepPurple 
                                      : Colors.black,
                                ),
                              ),
                              selected: isSelected,
                              onTap: () => _onCourseTap(course),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.deepPurpleAccent)
                                  : null,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
} 