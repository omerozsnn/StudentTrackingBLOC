import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/widgets/student/student_detail_card.dart';
import 'package:ogrenci_takip_sistemi/widgets/student/student_list_item.dart';
import 'package:ogrenci_takip_sistemi/utils/excel_exporter.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'student_add_page.dart';
import 'student_update_screen.dart';

class StudentSearchPage extends StatefulWidget {
  const StudentSearchPage({super.key});

  @override
  StudentSearchPageState createState() => StudentSearchPageState();
}

class StudentSearchPageState extends State<StudentSearchPage> {
  final TextEditingController searchController = TextEditingController();
  String _lastShownMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    // Sınıfları yükle
    context.read<ClassBloc>().add(LoadClassesForDropdown());

    // Kısa bir gecikme ile öğrenci listesini yükle
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final selectedClassName = getSelectedClassName();
        debugPrint('Initial load - Selected class: $selectedClassName');

        // Sınıf seçili ise o sınıfın öğrencilerini yükle, değilse tüm öğrencileri getir
        if (selectedClassName != null && selectedClassName.isNotEmpty) {
          context
              .read<StudentBloc>()
              .add(LoadStudentsByClass(selectedClassName));
        } else {
          // İlk açılışta tüm öğrencileri getir
          context.read<StudentBloc>().add(LoadStudents());
        }
      }
    });
  }

  // Öğrenci detaylarını getirme
  void _loadStudentDetails(int studentId) {
    debugPrint('Loading student details for ID: $studentId');

    // First show loading state to give immediate feedback
    context.read<StudentBloc>().add(StudentLoadingEvent());

    // Then load the student details
    context.read<StudentBloc>().add(LoadStudentDetails(studentId));

    // For debugging
    Future.delayed(const Duration(milliseconds: 500), () {
      final state = context.read<StudentBloc>().state;
      final selectedStudent = context.read<StudentBloc>().selectedStudent;
      debugPrint('Current state after selection: $state');
      debugPrint('Selected student: ${selectedStudent?.adSoyad ?? "None"}');
    });
  }

  Future<void> _addStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentAddPage()),
    );

    // If result is true, a student was successfully added
    if (result == true) {
      // Show a success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Öğrenci başarıyla eklendi!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the student list
      _refreshStudentList();
    }
  }

  // Öğrenci listesini yenile
  void _refreshStudentList() {
    try {
      final selectedClassName = getSelectedClassName();
      debugPrint(
          'Öğrenci listesi yenileniyor. Seçili sınıf: $selectedClassName');

      if (selectedClassName != null && selectedClassName.isNotEmpty) {
        // Eğer bir sınıf seçili ise, o sınıfa ait öğrencileri getir
        context.read<StudentBloc>().add(LoadStudentsByClass(selectedClassName));
      } else {
        // Eğer sınıf seçili değilse, tüm öğrencileri getir
        context.read<StudentBloc>().add(LoadStudents());
      }
    } catch (e) {
      debugPrint('Öğrenci listesi yenilenirken hata: $e');
    }
  }

  Future<void> _deleteStudent(int studentId) async {
    final confirm = await UIHelpers.showConfirmationDialog(
      context: context,
      title: 'Öğrenci Sil',
      content: 'Silmek istediğinize emin misiniz?',
    );

    if (confirm) {
      UIHelpers.showLoadingDialog(context, 'Öğrenci siliniyor...');
      context.read<StudentBloc>().add(DeleteStudent(studentId));
    }
  }

  Future<void> _updateStudent(Student student) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentUpdateScreen(student: student),
      ),
    );

    _refreshStudentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Arama'),
        backgroundColor: const Color(0xFF6C8997),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C8997), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Sol Panel - Arama ve Liste
              Expanded(
                flex: 2,
                child: _buildLeftPanel(),
              ),
              const SizedBox(width: 16),

              // Sağ Panel - Öğrenci Detayları
              Expanded(
                flex: 4,
                child: _buildRightPanel(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildLeftPanel() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arama Başlığı
            const Text(
              'Öğrenci Ara',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C8997),
              ),
            ),
            const SizedBox(height: 16),
            // Arama Alanı
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Öğrenci Adı veya Soyadı',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6C8997)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF6C8997), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sınıf Seçimi
            _buildClassDropdown(),

            const SizedBox(height: 16),
            // Arama Butonu
            ElevatedButton(
              onPressed: () {
                final searchText = searchController.text.trim();
                debugPrint('Arama butonu tıklandı. Arama metni: "$searchText"');

                if (searchText.isNotEmpty) {
                  // Arama yapılacaksa sınıf seçimini temizle
                  context.read<ClassBloc>().add(UnselectClass());

                  // Önce loading durumunu göster
                  context.read<StudentBloc>().add(StudentLoadingEvent());

                  // Kısa bir gecikme ile arama yap
                  Future.delayed(const Duration(milliseconds: 100), () {
                    context.read<StudentBloc>().add(SearchStudents(searchText));
                  });
                } else {
                  // Eğer sınıf seçili ise, o sınıfın öğrencilerini göster
                  final selectedClassName = getSelectedClassName();
                  if (selectedClassName != null &&
                      selectedClassName.isNotEmpty) {
                    debugPrint(
                        'Boş arama, seçili sınıf var: $selectedClassName');
                    context
                        .read<StudentBloc>()
                        .add(LoadStudentsByClass(selectedClassName));
                  } else {
                    // Sınıf seçili değilse, tüm öğrencileri göster
                    debugPrint(
                        'Boş arama, seçili sınıf yok, tüm öğrenciler getiriliyor');
                    context.read<StudentBloc>().add(LoadStudents());
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C8997),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('Ara'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Öğrenci Listesi
            Expanded(
              child: _buildStudentList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        // Yükleme durumunda loading göster
        if (state is ClassLoading) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Hata durumunda hata mesajı göster
        if (state is ClassError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Sınıflar yüklenemedi: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Sınıfları listeye dönüştür
        final classes = state is ClassesLoaded ? state.classes : <Classes>[];
        final selectedClass =
            state is ClassesLoaded ? state.selectedClass : null;

        if (classes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Sınıf bulunamadı'),
          );
        }

        // Dropdown menü oluştur
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Classes>(
              isExpanded: true,
              value: selectedClass,
              hint: const Text('Sınıf Seçin'),
              items: classes.map((classItem) {
                return DropdownMenuItem<Classes>(
                  value: classItem,
                  child: Row(
                    children: [
                      const Icon(Icons.class_, color: Color(0xFF6C8997)),
                      const SizedBox(width: 8),
                      Text(classItem.sinifAdi),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Classes? newValue) {
                if (newValue != null) {
                  // Daha önce aynı sınıf seçildiyse tekrar sorgu yapmayalım
                  final currentState = context.read<ClassBloc>().state;
                  final currentClass = currentState is ClassesLoaded
                      ? currentState.selectedClass
                      : null;

                  if (currentClass != null && currentClass.id == newValue.id) {
                    // Aynı sınıf seçildiyse işlem yapmaya gerek yok
                    return;
                  }

                  // Sınıfı seç
                  context.read<ClassBloc>().add(SelectClass(newValue));

                  // UI güncellemek için loading durumu göster
                  context.read<StudentBloc>().add(StudentLoadingEvent());

                  // Kısa bir gecikme sonra öğrencileri yükle
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      // BLoC ile sınıfa göre öğrencileri getir
                      context
                          .read<StudentBloc>()
                          .add(LoadStudentsByClass(newValue.sinifAdi));

                      // Debug için log ekleyelim
                      debugPrint(
                          'Sınıf seçildi: ${newValue.sinifAdi}, ID: ${newValue.id}');
                    }
                  });

                  // Arama metnini temizle
                  searchController.clear();
                }
              },
            ),
          ),
        );
      },
    );
  }

  String? getSelectedClassName() {
    final state = context.read<ClassBloc>().state;
    if (state is ClassesLoaded && state.selectedClass != null) {
      return state.selectedClass!.sinifAdi;
    } else {
      return context.read<StudentBloc>().selectedClass;
    }
  }

  Widget _buildStudentList() {
    return BlocConsumer<StudentBloc, StudentState>(
      listenWhen: (previous, current) {
        // Sadece belirli durumlar için dinleme yap
        return current is StudentError ||
            current is StudentOperationSuccess ||
            current is StudentOperationMessage;
      },
      listener: (context, state) {
        if (state is StudentError) {
          if (_lastShownMessage != state.message) {
            _lastShownMessage = state.message;
            UIHelpers.showErrorMessage(context, state.message);
          }
        } else if (state is StudentOperationSuccess) {
          if (_lastShownMessage != state.message) {
            _lastShownMessage = state.message;
            UIHelpers.showSuccessMessage(context, state.message);
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop(); // Hide loading dialog if visible
            }
          }
        } else if (state is StudentOperationMessage) {
          if (_lastShownMessage != state.message) {
            _lastShownMessage = state.message;
            // Bilgi mesajlarını göster
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }
      },
      buildWhen: (previous, current) {
        // Sadece belirli state değişikliklerinde yeniden oluştur
        // StudentSelected durumunda liste yeniden oluşturulmasın, böylece scroll konumu korunur
        if (current is StudentSelected && previous is StudentsLoaded) {
          return true; // Öğrenci seçildiğinde listeyi yeniden oluştur (was false)
        }
        return current is StudentsLoaded ||
            current is StudentLoading ||
            current is StudentInitial ||
            current is StudentSelected; // Add StudentSelected state here
      },
      builder: (context, state) {
        debugPrint("BlocConsumer state: $state");

        // Öğrenci listesini tut
        List<Student> students = [];
        Student? selectedStudent;
        bool isLoading = state is StudentLoading;

        // Duruma göre öğrenci listesini güncelle
        if (state is StudentsLoaded) {
          students = state.students;
          debugPrint("StudentsLoaded: ${students.length} öğrenci bulundu");
        } else if (state is StudentSelected) {
          students = state.students;
          selectedStudent = state.selectedStudent;
          debugPrint(
              "StudentSelected: ${students.length} öğrenci, seçili öğrenci: ${selectedStudent.adSoyad}");
        } else if (state is StudentInitial) {
          debugPrint("StudentInitial durumu");
        }

        // Öğrenci BLoC'tan seçili öğrenciyi al
        if (selectedStudent == null) {
          selectedStudent = context.read<StudentBloc>().selectedStudent;
        }

        // Eğer loading durumundaysa ve önceki öğrenciler yoksa loading göster
        if (isLoading && students.isEmpty) {
          return _buildLoadingIndicator();
        }

        // Öğrenci listesi var ve dolu
        if (students.isNotEmpty) {
          debugPrint(
              "Öğrenci listesi oluşturuluyor: ${students.length} öğrenci");
          return ListView.builder(
            key: const PageStorageKey<String>('studentListView'),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];

              // Check if this student is the selected one
              final isSelected =
                  selectedStudent != null && selectedStudent.id == student.id;

              if (isSelected) {
                debugPrint(
                    "Found selected student in list: ${student.adSoyad}");
              }

              return StudentListItem(
                student: student,
                isSelected: isSelected,
                onTap: () => _loadStudentDetails(student.id),
              );
            },
          );
        }

        // Öğrenci listesi boş
        final String? selectedClassName = getSelectedClassName();
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                selectedClassName != null && selectedClassName.isNotEmpty
                    ? '$selectedClassName sınıfında öğrenci bulunamadı'
                    : 'Öğrenci bulunamadı',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshStudentList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C8997),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Öğrencileri Yenile'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Öğrenciler Yükleniyor...',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: BlocConsumer<StudentBloc, StudentState>(
        listenWhen: (previous, current) {
          // Only listen for error states specifically related to student details
          return current is StudentError;
        },
        listener: (context, state) {
          // Handle errors related to loading student details
          if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Öğrenci detayları yüklenirken hata: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (previous, current) {
          // Only rebuild the UI for these specific states
          // Prevent rebuilds for photo loading states
          if (current is StudentPhotoLoaded) {
            return false; // Photo loading handled by the detail card itself
          }

          // Prevent rebuilds when transitioning from loading to selected if we already have a selected student
          if (previous is StudentLoading && current is StudentSelected) {
            return true; // Always rebuild when a student is selected after loading
          }

          // Prevent rebuilds for operation messages and success states
          if (current is StudentOperationMessage ||
              current is StudentOperationSuccess) {
            return false;
          }

          return current is StudentSelected ||
              current is StudentInitial ||
              (current is StudentLoading && previous is! StudentSelected);
        },
        builder: (context, state) {
          // Debug log for right panel state changes
          debugPrint("Right panel state: $state");

          // If a student is selected
          if (state is StudentSelected) {
            final student = state.selectedStudent;
            final className = getSelectedClassName();

            // Öğrenci detay bilgileri
            return StudentDetailCard(
              key: ValueKey<int>(
                  student.id), // Use student ID as key to maintain state
              student: student,
              className: className,
            );
          }
          // Handle loading state
          else if (state is StudentLoading) {
            // Check if we already have a selected student to show
            final currentStudent = context.read<StudentBloc>().selectedStudent;
            if (currentStudent != null) {
              final className = getSelectedClassName();
              return StudentDetailCard(
                key: ValueKey<int>(currentStudent.id),
                student: currentStudent,
                className: className,
              );
            }

            // Otherwise show loading indicator
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Öğrenci bilgileri yükleniyor...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          // Öğrenci seçili değilse boş panel göster
          else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Öğrenci detayları için listeden bir öğrenci seçin',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        // Seçili öğrenci varsa butonları göster
        final bool hasSelectedStudent = state is StudentSelected;
        final Student? selectedStudent = hasSelectedStudent
            ? (state as StudentSelected).selectedStudent
            : null;
        final List<Student> students = hasSelectedStudent
            ? (state as StudentSelected).students
            : (state is StudentsLoaded ? state.students : []);

        if (!hasSelectedStudent) {
          return FloatingActionButton(
            onPressed: _addStudent,
            backgroundColor: Colors.deepOrangeAccent,
            child: const Icon(Icons.add),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () => ExcelExporter.exportStudentsToExcel(
                    context,
                    students,
                    getSelectedClassName(),
                  ),
                  heroTag: 'excelileaktarma',
                  backgroundColor: Colors.blue,
                  child: Image.asset('assets/icons/sheet.png',
                      width: 24, height: 24),
                  tooltip: 'Excel\'e Aktar',
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: _addStudent,
                  heroTag: 'addStudent',
                  backgroundColor: Colors.deepOrangeAccent,
                  child: const Icon(Icons.add),
                  tooltip: 'Öğrenci Ekle',
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    if (selectedStudent != null) {
                      _deleteStudent(selectedStudent.id);
                    }
                  },
                  heroTag: 'deleteStudent',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete),
                  tooltip: 'Öğrenci Sil',
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    if (selectedStudent != null) {
                      _updateStudent(selectedStudent);
                    }
                  },
                  heroTag: 'updateStudent',
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.edit),
                  tooltip: 'Öğrenci Güncelle',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
