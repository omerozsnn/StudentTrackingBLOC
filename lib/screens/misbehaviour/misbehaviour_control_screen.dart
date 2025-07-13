import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatı için
import 'package:http/http.dart' as http; // HTTP istekleri için
import 'package:ogrenci_takip_sistemi/models/misbehaviour_model.dart';
import '../../api.dart/classApi.dart' as classApi;
import '../../api.dart/studentControlApi.dart' as studentApi;
import '../../api.dart/student_misbehaviour_api.dart' as misbehaviourApi;
import '../../api.dart/misbehaviorApi.dart' as misApi;

class MisbehaviourControlScreen extends StatefulWidget {
  const MisbehaviourControlScreen({super.key});

  @override
  _MisbehaviourControlScreenState createState() =>
      _MisbehaviourControlScreenState();
}

class _MisbehaviourControlScreenState extends State<MisbehaviourControlScreen> {
  final classApi.ApiService classApiService =
      classApi.ApiService(baseUrl: 'http://localhost:3000');
  final studentApi.StudentApiService studentApiService =
      studentApi.StudentApiService(baseUrl: 'http://localhost:3000');
  final misbehaviourApi.StudentMisbehaviourApiService misbehaviourApiService =
      misbehaviourApi.StudentMisbehaviourApiService(
          baseUrl: 'http://localhost:3000');
  final misApi.MisbehaviourApiService misApiService =
      misApi.MisbehaviourApiService(baseUrl: 'http://localhost:3000');

  List<String> classes = [];
  List<Map<String, dynamic>> students = [];
  List<Misbehaviour> misbehaviours = []; // Mevcut yaramazlıklar
  List<Map<String, dynamic>> assignedMisbehaviours =
      []; // Öğrenciye atanmış yaramazlıklar
  String? selectedClass;
  Map<String, dynamic>? selectedStudent;
  Misbehaviour? selectedMisbehaviour;
  DateTime selectedDate = DateTime.now();
  Uint8List? studentImage; // Öğrenci resmi için binary data
  Set<int> selectedStudentIds = {}; // Seçili öğrencilerin ID'lerini tutacak
  bool selectAllChecked = false; // Tümünü seç durumu

  final ScrollController _scrollController =
      ScrollController(); // ScrollController eklendi

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadMisbehaviours();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ScrollController'ı temizlemeyi unutmayın
    super.dispose();
  }

  // Çoklu atama için yeni fonksiyon
  Future<void> _assignMisbehaviourToMultipleStudents() async {
    if (selectedStudentIds.isEmpty || selectedMisbehaviour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen öğrenci(ler) ve yaramazlık seçin')),
      );
      return;
    }

    try {
      // İşlem başladığında loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Yaramazlık kayıtları ekleniyor...'),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Tüm seçili öğrenciler için yaramazlık kaydı ekle
      for (int studentId in selectedStudentIds) {
        await misbehaviourApiService.addStudentMisbehaviour(
          studentId,
          selectedDate.toIso8601String(),
          selectedMisbehaviour!.id!,
        );
      }

      // Loading dialogunu kapat
      Navigator.of(context).pop();

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${selectedStudentIds.length} öğrenciye yaramazlık kaydı eklendi.'),
      ));

      // Seçimleri sıfırla
      setState(() {
        selectedStudentIds.clear();
        selectAllChecked = false;
      });
    } catch (error) {
      // Loading dialogunu kapat
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Hata oluştu: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _loadClasses() async {
    try {
      final data = await classApiService.getClassesForDropdown();
      setState(() {
        classes = data
            .map<String>((classItem) => classItem.sinifAdi.toString())
            .toList();
      });
    } catch (error) {
      print('Sınıflar yüklenemedi: $error');
    }
  }

  Future<void> _loadStudents(String className) async {
    try {
      final classId = await classApiService.getClassIdByName(className);
      if (classId != null) {
        final studentData =
            await studentApiService.getStudentsByClassId(classId);
        setState(() {
          students = studentData.cast<Map<String, dynamic>>();
          selectedStudent = null;
          studentImage = null;
          assignedMisbehaviours = [];
          selectedStudentIds.clear(); // Seçimleri sıfırla
          selectAllChecked = false; // Tümünü seç durumunu sıfırla
        });
      }
    } catch (error) {
      print('Öğrenciler yüklenemedi: $error');
    }
  }

  Future<void> _loadMisbehaviours() async {
    try {
      final misbehaviourData = await misApiService.getAllMisbehaviours();
      setState(() {
        misbehaviours = misbehaviourData.cast<Misbehaviour>();
      });
    } catch (error) {
      print('Yaramazlık kayıtları yüklenemedi: $error');
    }
  }

  Future<void> _loadAssignedMisbehaviours() async {
    if (selectedStudent == null) return;

    try {
      final assignedData = await misbehaviourApiService
          .getMisbehavioursByStudentId(selectedStudent!['id']);
      setState(() {
        assignedMisbehaviours = assignedData.cast<Map<String, dynamic>>();
      });
    } catch (error) {
      print('Atanmış yaramazlıklar yüklenemedi: $error');
    }
  }

  Future<void> _loadStudentImage(int studentId) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/student/$studentId/image'));
      if (response.statusCode == 200) {
        setState(() {
          studentImage = response.bodyBytes;
        });
      } else {
        setState(() {
          studentImage = null; // Resim yüklenemediyse boş bırak
        });
      }
    } catch (error) {
      print('Öğrenci resmi yüklenemedi: $error');
      setState(() {
        studentImage = null;
      });
    }
  }

  Future<void> _assignMisbehaviour() async {
    if (selectedStudent == null || selectedMisbehaviour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen öğrenci ve yaramazlık seçin'),
        ),
      );
      return;
    }

    try {
      int ogrenciId = selectedStudent!['id'] as int;
      int misbehaviourId = selectedMisbehaviour!.id as int;
      String isoFormattedDate = selectedDate.toIso8601String();

      await misbehaviourApiService.addStudentMisbehaviour(
        ogrenciId,
        isoFormattedDate,
        misbehaviourId,
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Yaramazlık kaydı başarıyla eklendi.'),
      ));

      _loadAssignedMisbehaviours(); // Yeni eklenen kaydı listele
    } catch (error) {
      print('Yaramazlık kaydı eklenemedi: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Yaramazlık kaydı eklenemedi: $error'),
      ));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _deleteMisbehaviour(int id) async {
    try {
      await misbehaviourApiService.deleteStudentMisbehaviour(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Yaramazlık kaydı silindi.'),
      ));
      _loadAssignedMisbehaviours(); // Kaydı sildikten sonra listeyi güncelle
    } catch (error) {
      print('Yaramazlık kaydı silinemedi: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Yaramazlık kaydı silinemedi: $error'),
      ));
    }
  }

  void _showDeleteConfirmation(BuildContext context, int misbehaviourId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yaramazlık Kaydını Sil'),
          content: Text('Bu kaydı silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Sil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMisbehaviour(misbehaviourId);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStudentList() {
    return Column(
      children: [
        if (students.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Checkbox(
                  value: selectAllChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      selectAllChecked = value ?? false;
                      if (selectAllChecked) {
                        selectedStudentIds =
                            students.map((s) => s['id'] as int).toSet();
                      } else {
                        selectedStudentIds.clear();
                      }
                    });
                  },
                ),
                Text('Tümünü Seç'),
                Spacer(),
                Text('${selectedStudentIds.length} öğrenci seçili',
                    style: TextStyle(color: Color(0xFF6C8997))),
              ],
            ),
          ),
        Expanded(
          child: students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Lütfen bir sınıf seçin',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    var student = students[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CheckboxListTile(
                        value: selectedStudentIds.contains(student['id']),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value ?? false) {
                              selectedStudentIds.add(student['id']);
                              selectedStudent =
                                  student; // Son seçilen öğrenciyi aktif öğrenci yap
                            } else {
                              selectedStudentIds.remove(student['id']);
                              if (selectedStudent?['id'] == student['id']) {
                                selectedStudent = null;
                              }
                            }
                            selectAllChecked =
                                selectedStudentIds.length == students.length;
                          });
                          if (selectedStudent != null) {
                            _loadAssignedMisbehaviours();
                            _loadStudentImage(selectedStudent!['id']);
                          }
                        },
                        title: Text(
                            '${student['ogrenci_no'] ?? ''} - ${student['ad_soyad'] ?? 'Ad Soyad Yok'}'),
                        secondary: CircleAvatar(
                          backgroundColor: Color(0xFF6C8997),
                          child: Text(
                            student['ad_soyad']?[0] ?? '?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Öğrenci Seçimi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C8997),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedClass,
                            isExpanded: true,
                            hint: Text('Sınıf Seçin'),
                            items: classes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(Icons.class_,
                                        color: Color(0xFF6C8997)),
                                    SizedBox(width: 8),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedClass = newValue;
                                students = [];
                                assignedMisbehaviours = [];
                                selectedStudentIds.clear();
                                selectAllChecked = false;
                              });
                              if (newValue != null) _loadStudents(newValue);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(child: _buildStudentList()),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: selectedStudentIds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Lütfen öğrenci seçin',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people, color: Color(0xFF6C8997)),
                                SizedBox(width: 8),
                                Text(
                                  '${selectedStudentIds.length} Öğrenci Seçili',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6C8997),
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 24),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: Color(0xFF6C8997)),
                                SizedBox(width: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(selectedDate),
                                  style: TextStyle(fontSize: 16),
                                ),
                                Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () => _selectDate(context),
                                  icon: Icon(Icons.edit_calendar),
                                  label: Text('Tarih Seç'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF6C8997),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: misbehaviours.isEmpty
                                  ? Center(
                                      child: Text(
                                          'Yaramazlık tanımı bulunamadı',
                                          style:
                                              TextStyle(color: Colors.grey)))
                                  : GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 2.5,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: misbehaviours.length,
                                      itemBuilder: (context, index) {
                                        final misbehaviour =
                                            misbehaviours[index];
                                        return Card(
                                          elevation: 2,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedMisbehaviour =
                                                    misbehaviour;
                                              });
                                              if (selectedStudentIds.length >
                                                  1) {
                                                _assignMisbehaviourToMultipleStudents();
                                              } else {
                                                _assignMisbehaviour();
                                              }
                                            },
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: selectedMisbehaviour
                                                              ?.id ==
                                                          misbehaviour.id
                                                      ? Color(0xFF6C8997)
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    misbehaviour
                                                        .yaramazlikAdi,
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            if (selectedStudentIds.length == 1) ...[
                              Divider(height: 32),
                              Text(
                                'Yaramazlık Geçmişi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C8997),
                                ),
                              ),
                              SizedBox(height: 16),
                              Expanded(
                                child: assignedMisbehaviours.isEmpty
                                    ? Center(
                                        child: Text(
                                          'Henüz yaramazlık kaydı yok',
                                          style:
                                              TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount:
                                            assignedMisbehaviours.length,
                                        itemBuilder: (context, index) {
                                          var misbehaviour =
                                              assignedMisbehaviours[index];
                                          return Card(
                                            elevation: 1,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: ListTile(
                                              leading: Icon(Icons.warning,
                                                  color: Color(0xFF6C8997)),
                                              title: Text(misbehaviour[
                                                          'misbehaviour']
                                                      ?['yaramazlık_adi'] ??
                                                  ''),
                                              subtitle: Text(
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(DateTime.parse(
                                                          misbehaviour[
                                                              'tarih']))),
                                              trailing: IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _showDeleteConfirmation(
                                                        context,
                                                        misbehaviour['id']),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
