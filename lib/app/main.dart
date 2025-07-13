import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../api.dart/studentControlApi.dart';
import '../api.dart/teacherFeedbackApi.dart'
    as feedback_api;
import '../blocs/ogrenci_okul_denemeleri/ogrenci_okul_denemeleri_bloc.dart';
import '../blocs/ogrenci_okul_denemeleri/ogrenci_okul_denemeleri_repository.dart';
import '../blocs/prayer_surah/prayer_surah_bloc.dart';
import '../blocs/prayer_surah/prayer_surah_repository.dart';
import '../blocs/prayer_surah_student/prayer_surah_student_bloc.dart';
import '../blocs/prayer_surah_student/prayer_surah_student_repository.dart';
import '../blocs/student/student_bloc.dart';
import '../blocs/student/student_repository.dart';
import '../blocs/teacher_feedback/teacher_feedback_bloc.dart';
import '../api.dart/teacher_feedback_repository.dart';
import '../shared/widgets/google_style_calendar.dart';
import '../screens/deneme_sinavi/deneme_sinavi_add_screen.dart';
import '../screens/prayer_surah/prayer_surah_main_page.dart';
import '../screens/daily_tracking/daily_tracking_screen.dart';
import '../teacher_login_page.dart';
import '../teacher_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../egitimOgretimYılıEkle.dart';
import '../notEkranı.dart';
import '../teacherControl.dart';
import 'package:http/http.dart' as http; // HTTP kütüphanesi
import 'dart:convert'; // JSON parsing
import 'package:intl/date_symbol_data_local.dart'; // Yerel tarih bilgisi
import 'package:flutter_localizations/flutter_localizations.dart';
import '../screens/deneme_sinavi/deneme_screen.dart';
import '../screens/course/course_class_assign_page.dart';
import '../screens/deneme_sinavi/okul_denemesi_screen.dart';
import '../api.dart/okulDenemeleriApi.dart'
    as okul_denemesi_api;
import '../screens/exam_assignment/exam_assignment_screen.dart';
import '../screens/class/class_management_page.dart';
import '../screens/unit/unit_screen.dart';
import '../screens/misbehaviour/misbehaviour_management_screen.dart';
import '../api.dart/teacherApi.dart';
import '../screens/course/course_add_page.dart';
import '../screens/feedback/teacher_comment_screen.dart';
import '../screens/feedback/teacher_feedback_option_screen.dart';
import '../service/teacher_service.dart';
import '../yıllaraArasıAktarım.dart';
import '../screens/homework/homework_tracking_screen.dart';
import '../screens/homework/homework_screen.dart';
import '../screens/homework/homework_assignment_screen.dart';
import '../screens/student/student_search_page.dart';
import '../blocs/class/class_bloc.dart';
import '../blocs/class/class_repository.dart';
import '../api.dart/classApi.dart' as classApi;
import '../blocs/course_class/course_class_bloc.dart';
import '../blocs/course_class/course_class_repository.dart';
import '../api.dart/courseClassesApi.dart'
    as courseClassesApi;
import '../blocs/course/course_bloc.dart';
import '../blocs/course/course_repository.dart';
import '../api.dart/courseApi.dart' as courseApi;
import '../blocs/unit/unit_bloc.dart';
import '../blocs/unit/unit_repository.dart';
import '../api.dart/unitsApi.dart' as units_api;
import '../api.dart/denemeSınaviApi.dart'
    as deneme_sinavi_api;
import '../blocs/deneme_sinavi/deneme_sinavi_bloc.dart';
import '../blocs/deneme_sinavi/deneme_sinavi_repository.dart';
import '../blocs/ogrenci_deneme/ogrenci_deneme_bloc.dart';
import '../blocs/ogrenci_deneme/ogrenci_deneme_repository.dart';
import '../api.dart/ogrenciDenemeleriApi.dart';
import '../blocs/sinif_deneme/sinif_deneme_bloc.dart';
import '../blocs/sinif_deneme/sinif_deneme_repository.dart';
import '../api.dart/sınıfDenemeleriApi.dart'
    as sinif_denemeleri_api;
import '../blocs/kds/kds_bloc.dart';
import '../blocs/kds/kds_repository.dart';
import '../api.dart/kdsApi.dart';
import '../blocs/kds_class/kds_class_bloc.dart';
import '../blocs/kds_class/kds_class_repository.dart';
import '../api.dart/kds_class_api.dart';
import '../screens/kds/kds_assignment_screen.dart';
import '../screens/kds/kds_result_screen.dart';
import '../screens/kds/kds_screen.dart';
import '../blocs/grades/grades_bloc.dart';
import '../blocs/grades/grades_repository.dart';
import '../api.dart/grades_api.dart' as grades_api;
import '../blocs/course_class/course_class_event.dart';
import '../blocs/homework/homework_bloc.dart';
import '../blocs/homework/homework_repository.dart';
import '../blocs/student_homework/student_homework_bloc.dart';
import '../blocs/student_homework/student_homework_repository.dart';
import '../api.dart/studentHomeworkApi.dart';
import '../blocs/homework_tracking/homework_tracking_repository.dart';
import '../blocs/homework_tracking/homework_tracking_bloc.dart';
import '../blocs/defter_kitap/defter_kitap_bloc.dart';
import '../blocs/defter_kitap/defter_kitap_repository.dart';
import '../api.dart/defterKitapControlApi.dart';
import '../screens/defter_kitap/defter_kitap_tracking_screen.dart';
import '../blocs/okul_denemesi/okul_denemesi_bloc.dart';
import '../api.dart/ogrenciOkulDenemeleriApi.dart' as ogrenci_okul_denemeleri_api;
import '../screens/okul_denemesi/ogrenci_okul_denemeleri_screen.dart';
import '../api.dart/prayerSurahApi.dart';
import '../api.dart/prayerSurahStudentApi.dart';
import '../api.dart/classApi.dart' as class_api;
import '../blocs/prayer_surah_tracking/prayer_surah_tracking_bloc.dart';
import '../blocs/prayer_surah_tracking/prayer_surah_tracking_repository.dart';
import '../api.dart/prayerSurahTrackingControlApi.dart'
    as prayerSurahTrackingControlApi;
import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/dashboard_styles.dart';
import '../screens/course/course_management_page.dart';
import 'package:provider/provider.dart';
import '../screens/homework/homework_main_page.dart';
import '../screens/feedback/feedback_main_page.dart';
import '../screens/misbehaviour/misbehaviour_main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkTheme = false;
  bool _isLoading = true;
  Widget? _initialScreen;

  Future<void> _checkTeacher() async {
    final teacherService = TeacherService();
    final hasTeacher = await teacherService.hasTeacher();

    if (hasTeacher) {
      await fetchTeacherImage();
      _initialScreen = MyHomePage(
        toggleTheme: toggleTheme,
        isDarkTheme: isDarkTheme,
      );
    } else {
      _initialScreen = TeacherLoginPage();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  Future<String?> fetchTeacherImage() async {
    final teacherService = TeacherService();
    final teacherInfo = await teacherService.getTeacherInfo();
    String? imageUrl;

    if (teacherInfo != null) {
      try {
        final TeacherApiService apiService =
            TeacherApiService(baseUrl: AppConfig.baseUrl);
        imageUrl = await apiService.getTeacherImage(teacherInfo['id']);

        if (imageUrl != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('teacher_image', imageUrl);
        }
      } catch (e) {
        print("Öğretmen resmi yüklenemedi: $e");
      }
    }
    return imageUrl;
  }

  @override
  void initState() {
    super.initState();
    _checkTeacher();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
        providers: [
          BlocProvider<StudentBloc>(
            create: (context) => StudentBloc(
              repository: StudentRepository(
                apiService: StudentApiService(baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<ClassBloc>(
            create: (context) => ClassBloc(
              repository: ClassRepository(
                apiService: classApi.ApiService(),
              ),
            ),
          ),
          BlocProvider<CourseBloc>(
            create: (context) => CourseBloc(
              repository: CourseRepository(
                apiService:
                    courseApi.ApiService(baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<CourseClassBloc>(
            create: (context) => CourseClassBloc(
              repository: CourseClassRepository(
                apiService: courseClassesApi.ApiService(
                    baseUrl: 'http://localhost:3000'),
              ),
            )..add(LoadCourseClasses()),
          ),
          BlocProvider<UnitBloc>(
            create: (context) => UnitBloc(
              repository: UnitRepository(
                apiService:
                    units_api.ApiService(baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<KDSBloc>(
            create: (context) => KDSBloc(
              repository: KDSRepository(
                apiService: KDSApiService(baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<DenemeSinaviBloc>(
            create: (context) => DenemeSinaviBloc(
              repository: DenemeSinaviRepository(
                apiService: deneme_sinavi_api.ApiService(
                    baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<OgrenciDenemeBloc>(
            create: (context) => OgrenciDenemeBloc(
              repository: OgrenciDenemeRepository(
                apiService:
                    StudentExamRepository(baseUrl: "http://localhost:3000"),
              ),
            ),
          ),
          BlocProvider<SinifDenemeBloc>(
            create: (context) => SinifDenemeBloc(
              repository: SinifDenemeRepository(
                apiService: sinif_denemeleri_api.ApiService(),
              ),
            ),
          ),
          BlocProvider<KdsClassBloc>(
            create: (context) => KdsClassBloc(
              repository: KdsClassRepository(
                apiService:
                    KdsClassApiService(baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<KdsResultBloc>(
            create: (context) => KdsResultBloc(),
          ),
          BlocProvider<GradesBloc>(
            create: (context) => GradesBloc(
              repository: GradesRepository(
                apiService: grades_api.GradesRepository(
                    baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<HomeworkBloc>(
            create: (context) => HomeworkBloc(
              homeworkRepository: HomeworkRepository(),
            ),
          ),
          BlocProvider<StudentHomeworkBloc>(
            create: (context) => StudentHomeworkBloc(
              repository: StudentHomeworkRepository(
                apiService: StudentHomeworkApiService(),
              ),
            ),
          ),
          BlocProvider<HomeworkTrackingBloc>(
            create: (context) => HomeworkTrackingBloc(
              repository: HomeworkTrackingRepository(),
            ),
          ),
          BlocProvider<DefterKitapBloc>(
            create: (context) => DefterKitapBloc(
              repository: DefterKitapRepository(
                defterKitapApi: ApiService(baseUrl: 'http://localhost:3000'),
                studentApi: StudentApiService(baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<TeacherFeedbackBloc>(
            create: (context) => TeacherFeedbackBloc(
              repository: TeacherFeedbackRepository(
                apiService:
                    feedback_api.ApiService(baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<OkulDenemesiBloc>(
            create: (context) => OkulDenemesiBloc(
              apiService: okul_denemesi_api.ApiService(
                  baseUrl: 'http://localhost:3000'),
            ),
          ),
          BlocProvider<OgrenciOkulDenemeleriBloc>(
            create: (context) => OgrenciOkulDenemeleriBloc(
              repository: OgrenciOkulDenemeleriRepository(
                apiService: ogrenci_okul_denemeleri_api.ApiService(
                    baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<PrayerSurahBloc>(
            create: (context) => PrayerSurahBloc(
              repository: PrayerSurahRepository(
                apiService:
                    PrayerSurahApiService(baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
          BlocProvider<PrayerSurahStudentBloc>(
            create: (context) => PrayerSurahStudentBloc(
              repository: PrayerSurahStudentRepository(
                apiService: PrayerSurahStudentApiService(
                    baseUrl: 'http://localhost:3000'),
              ),
              studentApiService:
                  StudentApiService(baseUrl: 'http://localhost:3000'),
              classApiService:
                  class_api.ApiService(baseUrl: 'http://localhost:3000'),
            ),
          ),
          BlocProvider<PrayerSurahTrackingBloc>(
            create: (context) => PrayerSurahTrackingBloc(
              repository: PrayerSurahTrackingRepository(
                prayerSurahTrackingApiService:
                    prayerSurahTrackingControlApi.ApiService(
                        baseUrl: 'http://localhost:3000'),
                prayerSurahApiService:
                    PrayerSurahApiService(baseUrl: 'http://localhost:3000'),
                prayerSurahStudentApiService: PrayerSurahStudentApiService(
                    baseUrl: 'http://localhost:3000'),
                studentApiService:
                    StudentApiService(baseUrl: 'http://localhost:3000'),
                classApiService:
                    class_api.ApiService(baseUrl: 'http://localhost:3000'),
              ),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Öğrenci Takip Programı',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr', 'TR'),
          ],
          locale: const Locale('tr', 'TR'),
          home: _initialScreen,
        ));
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkTheme;

  const MyHomePage(
      {Key? key, required this.toggleTheme, required this.isDarkTheme})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<dynamic> upcomingHomeworks = [];
  String? teacherName;
  String? teacherImage;
  List<DateTime> _assignmentDueDates = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    fetchUpcomingHomeworks();
    fetchTeacherInfo();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> fetchTeacherInfo() async {
    final teacherService = TeacherService();
    final teacherInfo = await teacherService.getTeacherInfo();

    if (teacherInfo != null) {
      setState(() {
        teacherName = teacherInfo['name'];
      });
      final prefs = await SharedPreferences.getInstance();
      String? savedImage = prefs.getString('teacher_image');
      if (mounted) {
        setState(() {
          teacherImage = savedImage;
        });
      }
    }
  }

  Future<void> fetchUpcomingHomeworks() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/homeworks'));
      if (response.statusCode == 200) {
        List<dynamic> allHomeworks = json.decode(response.body);
        
        // Populate _assignmentDueDates from all homeworks
        List<DateTime> dueDates = [];
        for (var hw in allHomeworks) {
          if (hw['teslim_tarihi'] != null) {
            try {
              dueDates.add(DateTime.parse(hw['teslim_tarihi']));
            } catch (e) {
              print("Error parsing date for calendar: ${hw['teslim_tarihi']} - $e");
            }
          }
        }

        List<dynamic> filteredHomeworks = allHomeworks.where((homework) {
          DateTime dueDate = DateTime.parse(homework['teslim_tarihi']);
          return dueDate.isAfter(DateTime.now());
        }).toList();
        filteredHomeworks.sort((a, b) {
          DateTime dueDateA = DateTime.parse(a['teslim_tarihi']);
          DateTime dueDateB = DateTime.parse(b['teslim_tarihi']);
          return dueDateA.compareTo(dueDateB);
        });
        List<dynamic> topFiveHomeworks = filteredHomeworks.take(5).toList();
        if (mounted) {
            setState(() {
            upcomingHomeworks = topFiveHomeworks;
            _assignmentDueDates = dueDates;
            });
        }
      } else {
        print('Failed to load homeworks: ${response.statusCode}');
      }
    } catch (e) {
        print('Error fetching homeworks: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  String calculateRemainingDays(DateTime dueDate) {
    final Duration difference = dueDate.difference(DateTime.now());
    if (difference.inDays > 0) {
      return '${difference.inDays} Gün Kaldı!';
    } else if (difference.inDays == 0 && difference.inHours >=0) { 
      return 'Bugün Teslim!';
    } else if (difference.isNegative) {
      return 'Teslim Tarihi Geçti!';
    }
    if (difference.inDays == 0 && difference.inHours < 0) {
        return 'Teslim Tarihi Geçti!';
    }
    return '${difference.inDays} Gün Kaldı!'; 
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: DashboardStyles.panelTitleStyle.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    return _HoverableCardWidget( 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Takvim'), 
          Expanded(
            child: SingleChildScrollView( 
              child: GoogleStyleCalendar(assignmentDates: _assignmentDueDates),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAssignmentsCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _HoverableCardWidget( 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Yaklaşan Ödevler'),
          if (upcomingHomeworks.isEmpty)
            Expanded(
              child: Center(child: Text('Yaklaşan ödev bulunmamaktadır.', style: textTheme.bodyMedium)),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: upcomingHomeworks.length > 3 ? 3 : upcomingHomeworks.length,
                itemBuilder: (context, index) {
                  final homework = upcomingHomeworks[index];
                  DateTime dueDate = DateTime.parse(homework['teslim_tarihi']);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.assignment, color: Theme.of(context).colorScheme.secondary, size: 24),
                    title: Text(homework['odev_adi'], style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      calculateRemainingDays(dueDate),
                      style: textTheme.labelLarge,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentOfTheMonthCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final students = [
      {'name': 'Ayşe Yılmaz', 'icon': '🥇', 'score': '98%'},
      {'name': 'Mehmet Öztürk', 'icon': '🥈', 'score': '95%'},
      {'name': 'Fatma Kaya', 'icon': '🥉', 'score': '92%'},
      {'name': 'Ali Demir', 'icon': '🏅', 'score': '90%'}, 
    ];
    return _HoverableCardWidget( 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Ayın Öğrencisi Sıralaması'),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                  leading: Text(student['icon']!, style: TextStyle(fontSize: 24)), 
                  title: Text(student['name']!, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)), 
                  trailing: Text(student['score']!, style: textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actions = [
      {'label': 'Not Girişi', 'icon': Icons.add_chart, 'color': AppColors.accent, 'action': () => print('Add Grade')},
      {'label': 'Yoklama Al', 'icon': Icons.check_circle_outline, 'color': AppColors.secondary, 'action': () => print('Take Attendance')},
      {'label': 'Davranış Notu', 'icon': Icons.record_voice_over, 'color': AppColors.warning, 'action': () => print('Behavior Note')},
      {'label': 'Ödül Ver', 'icon': Icons.emoji_events, 'color': AppColors.warning, 'action': () => print('Give Award')},
      {'label': 'Rapor Oluştur', 'icon': Icons.assessment, 'color': AppColors.primary, 'action': () => print('New Report')},
      {'label': 'Veli İletişim', 'icon': Icons.contact_mail, 'color': AppColors.info, 'action': () => print('Parent Contact')},
    ];
    return _HoverableCardWidget( 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Hızlı İşlemler'),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, 
              mainAxisSpacing: 12,  
              childAspectRatio: 0.9, 
              children: actions.map((action) {
                return InkWell(
                  onTap: action['action'] as VoidCallback,
                  borderRadius: BorderRadius.circular(8), 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action['icon'] as IconData, size: 30, color: action['color'] as Color), 
                      SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        textAlign: TextAlign.center,
                        style: textTheme.labelLarge?.copyWith(fontSize: 11), 
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentActivitiesCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activities = [
      {'title': 'Not Girişi', 'subtitle': 'Matematik Testi Q2 Güncellendi', 'icon': Icons.grading, 'base_color': AppColors.accent},
      {'title': 'Yoklama Kaydı', 'subtitle': 'Sınıf 5B - %95 Katılım', 'icon': Icons.event_available, 'base_color': AppColors.secondary},
      {'title': 'Rapor Oluşturuldu', 'subtitle': 'Öğrenci Gelişim Q2', 'icon': Icons.document_scanner, 'base_color': AppColors.warning},
    ];
    return _HoverableCardWidget( 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Son Aktiviteler'),
          Padding( 
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: activities.map((activity) {
                final baseColor = activity['base_color'] as Color;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0), 
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 26, 
                          backgroundColor: baseColor.withOpacity(0.15),
                          child: Icon(activity['icon'] as IconData, color: baseColor, size: 26), 
                        ),
                        SizedBox(height: 10),
                        Text(
                          activity['title'] as String,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500), 
                        ),
                        SizedBox(height: 4),
                        Text(
                          activity['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: textTheme.labelLarge, 
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    // Use onPrimary color for text/icons on primary background for good contrast
    final sidebarTextColor = theme.colorScheme.onPrimary; 
    final sidebarIconColor = theme.colorScheme.onPrimary;

    return Container(
      width: 280,
      color: AppColors.primary, // Sidebar background
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50, // Target 50px radius
                  backgroundImage: teacherImage != null && teacherImage!.isNotEmpty
                      ? NetworkImage(teacherImage!)
                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(height: 12),
                Text(
                  teacherName ?? 'Yükleniyor...',
                  style: TextStyle(
                    color: sidebarTextColor,
                    fontSize: 18, // Adjusted for sidebar
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          buildMenuTile(context, 'Öğretmen', Icons.person_4, ['Öğrenci Takip'], isSidebar: true),
          buildMenuTile(context, 'Öğrenci', Icons.person, [
            'Öğrenci Bilgileri', 'Öğretmen Görüşü', 'Defter Kitap Kontrol',
            'Yaramazlık Kontrol', "Not Ekranı", 'KDS Kontrol Ekranı',
            'Deneme Sınavı Ekranı', 'Okul Deneme Ekranı', 'Öğrenci Soru Takibi'
          ], isSidebar: true),
          buildMenuTile(context, 'Atama İşlemleri', Icons.assignment, [
            'Yıl Atama', 'KDS Atama', 'Deneme Sınavı Atama'
          ], isSidebar: true),
          buildMenuTile(context, 'Bilgi Girişi', Icons.input, [
            'Sınıflar', 'Dersler', 'Sure ve Dua', 'Ödev', 'Yaramazlık', 'Unite',
            'KDS Ekle', 'Deneme Sınavı Ekle', 'Okul Denemesi Ekle',
            'Eğitim Öğretim Yılı Ekle'
          ], isSidebar: true),
          buildMenuTile(context, 'Profil', Icons.settings,
              ['Hesabım', 'Sistem Ayarları'],
              isSidebar: true),
          buildMenuTile(context, 'Hakkında', Icons.info, ['Versiyon Bilgisi', 'Yardım'], isSidebar: true),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Content Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                "Dashboard",
                style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onBackground),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: theme.iconTheme.color),
                tooltip: "Yenile",
                onPressed: () {
                  // Placeholder for refresh action
                  fetchUpcomingHomeworks();
                  fetchTeacherInfo();
                },
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.upload_file, color: theme.iconTheme.color),
                tooltip: "Rapor Al",
                onPressed: () {
                  // Placeholder for report action
                },
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.add_circle_outline, size: 18),
                label: Text("Yeni Öğrenci"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success, // Green
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Placeholder for new student action
                },
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.edit_note, size: 18),
                label: Text("Hızlı Not Gir"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary, // Blue
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Placeholder for quick note action
                },
              ),
            ],
          ),
        ),
        // Dashboard Panels
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0), // Adjust padding
            child: Column(
              children: [
                SizedBox(
                  height: 300.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildCalendarCard(context)),
                      SizedBox(width: 16),
                      Expanded(child: _buildUpcomingAssignmentsCard(context)),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 300.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildStudentOfTheMonthCard(context)),
                      SizedBox(width: 16),
                      Expanded(child: _buildQuickActionsCard(context)),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _buildRecentActivitiesCard(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Öğrenci Takip Programı'), 
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline),
            tooltip: 'Hesabım',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeacherProfilePage()),
              );
            },
          ),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4), 
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning, 
                    Color.lerp(AppColors.warning, 
                               theme.brightness == Brightness.dark ? Colors.black : Colors.black54, 
                               0.2)!
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.star, color: Colors.white),
                tooltip: 'Pro Yükseltme',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pro Yükseltme tıklandı (yer tutucu).')),
                  );
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            tooltip: widget.isDarkTheme ? "Aydınlık Mod'a Geç" : "Karanlık Mod'a Geç",
            onPressed: widget.toggleTheme,
          ),
          SizedBox(width: 8), 
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: _buildMainContent(context),
          ),
        ],
      ),
    );
  }

  Widget buildMenuTile(
    BuildContext context, String title, IconData icon, List<String> options, {bool isSidebar = false}) {
    final theme = Theme.of(context);
    
    // Determine text and icon colors based on context (sidebar or drawer)
    final Color tileTextColor = isSidebar ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    final Color tileIconColor = isSidebar ? theme.colorScheme.onPrimary : (theme.iconTheme.color ?? theme.colorScheme.primary);
    final Color assetIconColor = isSidebar ? theme.colorScheme.onPrimary : theme.colorScheme.primary;


    Widget leadingIcon;
    switch (title) {
      case 'Öğretmen':
        leadingIcon = Image.asset('assets/icons/teacher.png', width: 24, height: 24, color: assetIconColor);
        break;
      case 'Öğrenci':
        leadingIcon = Image.asset('assets/icons/student.png', width: 24, height: 24, color: assetIconColor);
        break;
      case 'Atama İşlemleri':
        leadingIcon = Image.asset('assets/icons/assignment.png', width: 24, height: 24, color: assetIconColor);
        break;
      case 'Bilgi Girişi':
        leadingIcon = Image.asset('assets/icons/data.png', width: 24, height: 24, color: assetIconColor);
        break;
      case 'Profil':
        leadingIcon = Image.asset('assets/icons/user-account.png', width: 24, height: 24, color: assetIconColor);
        break;
      case 'Hakkında':
        leadingIcon = Image.asset('assets/icons/about.png', width: 24, height: 24, color: assetIconColor);
        break;
      default:
        leadingIcon = Icon(icon, color: tileIconColor);
    }

    return ExpansionTile(
      leading: leadingIcon,
      title: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: tileTextColor)),
      iconColor: tileIconColor, 
      collapsedIconColor: tileIconColor,
      children: options.map<Widget>((String choice) {
        return ListTile(
          leading: Icon(Icons.arrow_right, color: tileIconColor.withOpacity(0.7)),
          title: Text(
            choice,
            style: theme.textTheme.bodyLarge?.copyWith(color: tileTextColor.withOpacity(0.9)),
          ),
          onTap: () {
            if (isSidebar) {
              // Navigator.pop(context); // No need to pop if it's a permanent sidebar
            } else {
              Navigator.pop(context); // For drawer behavior
            }
            
            // Navigation logic remains the same
            if (choice == 'Öğrenci Takip') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeacherControl()),
              );
            } else if (choice == 'Öğrenci Bilgileri') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StudentSearchPage()),
              );
            } else if (choice == 'Yaramazlık Kontrol') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MisbehaviourMainPage()),
              );
            } else if (choice == 'Öğrenci Soru Takibi') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DailyTrackingScreen()),
              );
            } else if (choice == 'Defter Kitap Kontrol') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DefterKitapTrackingScreen(),
                ),
              );
            } else if (choice == 'Öğretmen Görüşü') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackMainPage()),
              );
            } else if (choice == 'Sure ve Dua') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrayerSurahMainPage()),
              );
            } else if (choice == 'Okul Deneme Ekranı') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OgrenciOkulDenemeleriScreen()));
            } else if (choice == 'Dersler') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CourseManagementPage()),
              );
            } else if (choice == 'Yıl Atama') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BilgiAktarmaPage()),
              );
            } else if (choice == 'Ödev') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeworkMainPage()),
              );
            } else if (choice == 'Ödev Kontrol') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeworkTrackingScreen()),
              );
            } else if (choice == 'Sınıflar') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClassManagementPage()),
              );
            } else if (choice == 'Ödev Atama') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeworkAssignmentScreen()),
              );
            } else if (choice == 'Yaramazlık') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MisbehaviourMainPage()),
              );
            } else if (choice == 'Unite') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UnitScreen()),
              );
            } else if (choice == 'KDS Ekle') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KDSScreenNew()),
              );
            } else if (choice == 'KDS Atama') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KdsAssignmentScreen()),
              );
            } else if (choice == 'KDS Kontrol Ekranı') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KdsResultScreen()),
              );
            } else if (choice == 'Deneme Sınavı Ekle') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddDenemeSinaviScreen()),
              );
            } else if (choice == 'Deneme Sınavı Atama') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExamAssignmentScreen()),
              );
            } else if (choice == 'Deneme Sınavı Ekranı') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DenemeScreen()),
              );
            } else if (choice == 'Okul Denemesi Ekle') {
              final apiService = okul_denemesi_api.ApiService(
                  baseUrl: 'http://localhost:3000');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OkulDenemesiScreen(apiService: apiService),
                ),
              );
            } else if (choice == 'Eğitim Öğretim Yılı Ekle') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEducationYearPage()),
              );
            } else if (choice == 'Not Ekranı') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GradeTrackingPage()),
              );
            } else if (choice == 'Hesabım') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherProfilePage(),
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }
}

class _HoverableCardWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _HoverableCardWidget({Key? key, required this.child, this.onTap}) : super(key: key);

  @override
  _HoverableCardWidgetState createState() => _HoverableCardWidgetState();
}

class _HoverableCardWidgetState extends State<_HoverableCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    final effectiveElevation = _isHovered ? (cardTheme.elevation ?? 4) + 4 : (cardTheme.elevation ?? 4);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic, 
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          elevation: effectiveElevation,
          shape: cardTheme.shape, 
          color: cardTheme.color, 
          margin: cardTheme.margin, 
          child: Padding(
            padding: EdgeInsets.all(16), 
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeIn({Key? key, required this.child, this.delay = Duration.zero})
      : super(key: key);

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    Future.delayed(widget.delay, () {
      if (mounted) { 
        _controller.forward();
      }
    });

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder( 
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child, 
        );
      },
    );
  }
}

class GlobalContext {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get currentContext {
    return navigatorKey.currentContext;
  }
} 