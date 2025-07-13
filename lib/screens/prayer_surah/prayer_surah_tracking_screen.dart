import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_tracking/prayer_surah_tracking_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_tracking/prayer_surah_tracking_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_tracking/prayer_surah_tracking_state.dart';
import 'package:ogrenci_takip_sistemi/class_prayer_surah_tracking_page.dart';
import 'package:ogrenci_takip_sistemi/screens/prayer_surah/prayer_surah_management_page.dart';
import 'package:ogrenci_takip_sistemi/student_prayer_surah_tracking_screen.dart';
import 'package:ogrenci_takip_sistemi/widgets/prayer_surah/student_tracking_list.dart';

class PrayerSurahTrackingScreen extends StatefulWidget {
  const PrayerSurahTrackingScreen({super.key});

  @override
  _PrayerSurahTrackingScreenState createState() =>
      _PrayerSurahTrackingScreenState();
}

class _PrayerSurahTrackingScreenState extends State<PrayerSurahTrackingScreen> {
  final Map<int, SingleValueDropDownController> dropdownControllers = {};

  final List<DropDownValueModel> options = [
    const DropDownValueModel(name: 'Seçiniz', value: ''), // Empty option
    const DropDownValueModel(name: 'Güzel okudu', value: 'Güzel okudu'),
    const DropDownValueModel(
        name: 'Mükemmel okudu, Örnek bir okuyuş oldu',
        value: 'Mükemmel okudu, Örnek bir okuyuş oldu'),
    const DropDownValueModel(
        name: 'Kelime telaffuzlarında hatalar var',
        value: 'Kelime telaffuzlarında hatalar var'),
    const DropDownValueModel(
        name: 'Uzatmalarda küçük hatalar var',
        value: 'Uzatmalarda küçük hatalar var'),
    const DropDownValueModel(
        name: 'Söz hakkı verildi ama okumadı',
        value: 'Söz hakkı verildi ama okumadı'),
    const DropDownValueModel(
        name: 'Sure ve dua okuduğumuz gün okula gelmedi',
        value: 'Sure ve dua okuduğumuz gün okula gelmedi'),
    const DropDownValueModel(
        name: 'Daha güzel ve hatasız okuması için tekrar dinlenecek',
        value: 'Daha güzel ve hatasız okuması için tekrar dinlenecek'),
  ];

  @override
  void initState() {
    super.initState();
    // Load classes when the screen initializes
    context.read<PrayerSurahTrackingBloc>().add(LoadClasses());
  }

  @override
  void dispose() {
    // Dispose dropdown controllers
    dropdownControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerSurahTrackingBloc, PrayerSurahTrackingState>(
      listener: (context, state) {
        if (state.status == PrayerSurahTrackingStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Sınıf Takip Listesi'),
                  onPressed: () => _navigateToClassTrackingPage(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Headers
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      'Sınıflar',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: Text(
                      'Sınıfa Atanan Dua ve Sure Listesi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: Text(
                      'Öğrenci Bilgileri',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              // Class and Dua/Sure Lists
              _buildTopSection(context, state),
              const SizedBox(height: 16),
              // Student List
              Expanded(
                child: Card(
                  elevation: 2,
                  child: StudentTrackingList(
                    students: state.students,
                    studentTrackings: state.studentTrackings,
                    dropdownControllers: dropdownControllers,
                    options: options,
                    onStatusChanged: (studentId, value) {
                      context.read<PrayerSurahTrackingBloc>().add(
                            UpdateStudentTrackingStatus(
                                studentId, value ? 'Okudu' : 'Okumadı'),
                          );
                    },
                    onDegerlendirmeChanged: (studentId, value) {
                      context.read<PrayerSurahTrackingBloc>().add(
                            UpdateStudentTrackingDegerlendirme(
                                studentId, value),
                          );
                    },
                    onEkGorusChanged: (studentId, value) {
                      context.read<PrayerSurahTrackingBloc>().add(
                            UpdateStudentTrackingEkGorus(studentId, value),
                          );
                    },
                    onStudentSelected: (studentId) {
                      context.read<PrayerSurahTrackingBloc>().add(
                            SelectStudent(studentId),
                          );
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSection(
      BuildContext context, PrayerSurahTrackingState state) {
    final bloc = context.read<PrayerSurahTrackingBloc>();

    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel: Class List
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200, // List height
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _buildClassList(context, state),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),

          // Middle Panel: Surah/Dua Cards and Student Image
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Surah and Dua Cards
                Expanded(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: _buildSurahDuaList(context, state),
                  ),
                ),
                const SizedBox(width: 50.0),
                // Selected Student Info
                Expanded(
                  flex: 2,
                  child: bloc.selectedStudent != null
                      ? Row(
                          children: [
                            // Student info visible
                            Card(
                              elevation: 4,
                              child: ClipRRect(
                                child: Container(
                                  width: 200, // Card width
                                  height: 200, // Card height
                                  color: Colors.grey[
                                      300], // Background color (if image fails to load)
                                  child: bloc.studentImage != null
                                      ? Image.memory(
                                          bloc.studentImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.person,
                                          size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 75, bottom: 100),
                              child: Column(
                                children: [
                                  Text(
                                    bloc.selectedStudent!.ogrenciNo ?? '',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bloc.selectedStudent!.adSoyad,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _saveTrackings(context, state),
                                        icon: const Icon(Icons.save),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 35),
                                        child: IconButton(
                                          onPressed: () =>
                                              _navigateToStudentTrackingPage(
                                                  context,
                                                  bloc.selectedStudent!.id),
                                          icon: const Icon(Icons.print),
                                          alignment:
                                              AlignmentDirectional.topStart,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          children: [
                            // Empty area placeholder
                            SizedBox(height: 80), // Space for image
                            Text(
                              'Öğrenci seçilmedi',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(BuildContext context, PrayerSurahTrackingState state) {
    final classes = state.classes;

    if (state.status == PrayerSurahTrackingStatus.loading && classes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final String className = classes[index];
        final bool isSelected = state.selectedClass == className;

        return GestureDetector(
          onTap: () {
            context.read<PrayerSurahTrackingBloc>().add(SelectClass(className));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
                  : Colors.white,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                className,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.black87,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahDuaList(
      BuildContext context, PrayerSurahTrackingState state) {
    final surahDuaList = state.assignedSurahDuaList;

    if (state.status == PrayerSurahTrackingStatus.loading &&
        surahDuaList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.selectedClass == null) {
      return const Center(child: Text('Lütfen bir sınıf seçin'));
    }

    if (surahDuaList.isEmpty) {
      return const Center(child: Text('Bu sınıfa atanmış sure/dua bulunmuyor'));
    }

    return ListView.builder(
      itemCount: surahDuaList.length,
      itemBuilder: (context, index) {
        final surahDua = surahDuaList[index];
        final bool isSelected =
            state.selectedSurahDuaId == surahDua['dua_sure_id'];

        return GestureDetector(
          onTap: () {
            context.read<PrayerSurahTrackingBloc>().add(
                  SelectSurahDua(surahDua['dua_sure_id']),
                );
          },
          child: Card(
            color: isSelected ? Colors.blueGrey[100] : Colors.white,
            elevation: isSelected ? 6 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: isSelected
                  ? const BorderSide(color: Colors.blueGrey, width: 2)
                  : BorderSide.none,
            ),
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            child: ListTile(
              title: Text(
                surahDua['dua_sure_adi'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.blueGrey : Colors.black87,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.blueGrey)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  void _saveTrackings(
      BuildContext context, PrayerSurahTrackingState state) async {
    if (state.selectedSurahDuaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir sure/dua seçin')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Get all student IDs
      final List<int> studentIds =
          state.students.map((student) => student.id).toList();

      // Save the trackings
      context.read<PrayerSurahTrackingBloc>().add(
            SaveTrackings(
              studentIds: studentIds,
              surahDuaId: state.selectedSurahDuaId!,
            ),
          );

      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Değerlendirmeler kaydedildi')),
      );
    } catch (error) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $error')),
      );
    }
  }

  void _navigateToStudentTrackingPage(BuildContext context, int studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SudentPrayerSurahScreen(studentId: studentId),
      ),
    );
  }

  void _navigateToClassTrackingPage(BuildContext context) {
    final state = context.read<PrayerSurahTrackingBloc>().state;
    if (state.selectedClass != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ClassPrayerSurahTrackingPage(className: state.selectedClass!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce bir sınıf seçin')),
      );
    }
  }
}
