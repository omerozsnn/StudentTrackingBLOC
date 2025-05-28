import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/api.dart/studentControlApi.dart';
import 'package:ogrenci_takip_sistemi/api.dart/teacherFeedbackApi.dart'
    as feedback_api;
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_okul_denemeleri/ogrenci_okul_denemeleri_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_okul_denemeleri/ogrenci_okul_denemeleri_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_student/prayer_surah_student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_student/prayer_surah_student_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_feedback/teacher_feedback_bloc.dart';
import 'package:ogrenci_takip_sistemi/api.dart/teacher_feedback_repository.dart';
import 'package:ogrenci_takip_sistemi/custom_scroll_behavior.dart';
import 'package:ogrenci_takip_sistemi/google_style_calendar.dart';
import 'package:ogrenci_takip_sistemi/screens/deneme_sinavi/deneme_sinavi_add_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/prayer_surah/prayer_surah_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/prayer_surah/prayer_surah_assignment_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/prayer_surah/prayer_surah_tracking_screen.dart';
import 'package:provider/provider.dart';
import 'daily_tracking_page.dart';
import 'package:ogrenci_takip_sistemi/teacher_login_page.dart';
import 'package:ogrenci_takip_sistemi/teacher_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/egitimOgretimYılıEkle.dart';
import '/notEkranı.dart';
import '/teacherControl.dart';
import 'package:http/http.dart' as http; // HTTP kütüphanesi
import 'dart:convert'; // JSON parsing
import 'package:intl/date_symbol_data_local.dart'; // Yerel tarih bilgisi
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ogrenci_takip_sistemi/screens/deneme_sinavi/deneme_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/course/course_class_assign_page.dart';
import 'package:ogrenci_takip_sistemi/screens/deneme_sinavi/okul_denemesi_screen.dart';
import 'package:ogrenci_takip_sistemi/api.dart/okulDenemeleriApi.dart'
    as okul_denemesi_api;
import 'package:ogrenci_takip_sistemi/screens/exam_assignment/exam_assignment_screen.dart';
import 'screens/class/class_add_page.dart';
import 'package:ogrenci_takip_sistemi/screens/unit/unit_screen.dart';
import '/yaramazlık.dart';
import 'api.dart/teacherApi.dart';
import 'package:ogrenci_takip_sistemi/screens/course/course_add_page.dart';
import 'package:ogrenci_takip_sistemi/screens/feedback/teacher_comment_screen.dart';
import 'screens/feedback/teacher_feedback_option_screen.dart';
import 'service/teacher_service.dart';
import 'yaramazlikkontrol.dart';
import 'yıllaraArasıAktarım.dart';
import 'package:ogrenci_takip_sistemi/screens/homework/homework_tracking_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/homework/homework_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/homework/homework_assignment_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/student/student_search_page.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart' as classApi;
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/courseClassesApi.dart'
    as courseClassesApi;
import 'package:ogrenci_takip_sistemi/blocs/course/course_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/courseApi.dart' as courseApi;
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/unitsApi.dart' as units_api;
import 'package:ogrenci_takip_sistemi/api.dart/denemeSınaviApi.dart'
    as deneme_sinavi_api;
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/ogrenciDenemeleriApi.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/sınıfDenemeleriApi.dart'
    as sinif_denemeleri_api;
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/kdsApi.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds_class/kds_class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds_class/kds_class_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/kds_class_api.dart';
import 'package:ogrenci_takip_sistemi/screens/kds/kds_assignment_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/kds/kds_result_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/kds/kds_screen.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/grades_api.dart' as grades_api;
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/homework/homework_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/homework/homework_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/student_homework/student_homework_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student_homework/student_homework_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/studentHomeworkApi.dart';
import 'blocs/homework_tracking/homework_tracking_repository.dart';
import 'blocs/homework_tracking/homework_tracking_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/defterKitapControlApi.dart';
import 'package:ogrenci_takip_sistemi/screens/defter_kitap/defter_kitap_tracking_screen.dart';
import 'package:ogrenci_takip_sistemi/blocs/okul_denemesi/okul_denemesi_bloc.dart';
import 'api.dart/ogrenciOkulDenemeleriApi.dart' as ogrenci_okul_denemeleri_api;
import 'screens/okul_denemesi/ogrenci_okul_denemeleri_screen.dart';
import 'package:ogrenci_takip_sistemi/api.dart/prayerSurahApi.dart';
import 'package:ogrenci_takip_sistemi/api.dart/prayerSurahStudentApi.dart';
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart' as class_api;
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_tracking/prayer_surah_tracking_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_tracking/prayer_surah_tracking_repository.dart';
import 'package:ogrenci_takip_sistemi/api.dart/prayerSurahTrackingControlApi.dart'
    as prayerSurahTrackingControlApi;

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
  bool isDarkTheme = false; // Tema değişkeni
  bool _isLoading = true;
  Widget? _initialScreen;
  String? teacherImage;

  Future<void> _checkTeacher() async {
    final teacherService = TeacherService();
    final hasTeacher = await teacherService.hasTeacher();

    if (hasTeacher) {
      // Öğretmenin resmini çek
      await fetchTeacherImage();
      _initialScreen =
          MyHomePage(toggleTheme: toggleTheme, isDarkTheme: isDarkTheme);
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

  Future<void> fetchTeacherImage() async {
    final teacherService = TeacherService();
    final teacherInfo = await teacherService.getTeacherInfo();

    if (teacherInfo != null) {
      try {
        final TeacherApiService apiService =
            TeacherApiService(baseUrl: 'http://localhost:3000');
        String? imageUrl = await apiService.getTeacherImage(teacherInfo['id']);

        if (imageUrl != null) {
          // Öğretmen resmini SharedPreferences'a kaydet
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('teacher_image', imageUrl);

          setState(() {
            teacherImage = imageUrl;
          });
        }
      } catch (e) {
        print("Öğretmen resmi yüklenemedi: $e");
      }
    }
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Colors.blueGrey,
      scaffoldBackgroundColor: Colors.blueGrey[50], // Tema rengini koru
      colorScheme: ColorScheme.light(
        primary: Colors.blueGrey,
        secondary: Colors.orange,
        surface: Colors.white, // Daha açık ton
        background: Colors.grey[200], // Tema rengini koru
        error: Colors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blueGrey[500], // Tema rengini koru
        foregroundColor: Colors.black87,
        elevation: 1,
        titleTextStyle: TextStyle(
          color: const Color.fromARGB(221, 0, 0, 0),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white, // Açık ton kart rengi
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.black87),
        displayMedium: TextStyle(color: Colors.black87),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100], // Hafif gri form alanları
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.black87),
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey[100]),
          elevation: MaterialStateProperty.all(4),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkTeacher();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      GlobalContext.initialize(context);
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
          // OkulDenemesi BLoC provider
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
          theme: isDarkTheme ? ThemeData.dark() : _buildLightTheme(),
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
  final VoidCallback toggleTheme; // Tema değiştirme fonksiyonu
  final bool isDarkTheme;
  const MyHomePage(
      {Key? key, required this.toggleTheme, required this.isDarkTheme})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> upcomingHomeworks = [];
  String weatherEmoji = '☁'; // Hava durumu için emoji
  String weatherInfo = ''; // Hava durumu bilgisi
  String? currentYear; // Aktif eğitim yılı
  String? teacherName;
  String? teacherImage;

  @override
  void initState() {
    super.initState();
    fetchUpcomingHomeworks();
    fetchWeather();
    fetchCurrentYear();
    fetchTeacherInfo();
  }

  Future<void> fetchTeacherInfo() async {
    final teacherService = TeacherService();
    final teacherInfo = await teacherService.getTeacherInfo();

    if (teacherInfo != null) {
      setState(() {
        teacherName = teacherInfo['name'];
      });

      // Resmi SharedPreferences'tan al
      final prefs = await SharedPreferences.getInstance();
      String? savedImage = prefs.getString('teacher_image');
      setState(() {
        teacherImage = savedImage;
      });
    }
  }

  // Hava durumu API'si
  Future<void> fetchWeather() async {
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=41.0082&longitude=28.9784&current_weather=true'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      int weatherCode = data['current_weather']['weathercode'];

      // Map weather code to an emoji
      String emoji = getWeatherEmoji(weatherCode);

      setState(() {
        weatherInfo = "${data['current_weather']['temperature']}°C $emoji";
      });
    } else {
      setState(() {
        weatherInfo = "Hava durumu alınamadı.";
      });
    }
  }

  Future<void> fetchCurrentYear() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3000/egitim-ogretim-yillari/current'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          currentYear = data['egitim_ogretim_yili'];
        });
      }
    } catch (error) {
      setState(() {
        currentYear = "Yıl bilgisi alınamadı.";
      });
    }
  }

  // Hava durumuna göre emoji belirleyen fonksiyon
  String getWeatherEmoji(int weatherCode) {
    if (weatherCode == 1 || weatherCode == 2) {
      return "☀"; // Güneşli
    } else if (weatherCode == 3) {
      return "🌤"; // Parçalı bulutlu
    } else if (weatherCode == 45 || weatherCode == 48) {
      return "🌫"; // Sisli
    } else if (weatherCode >= 51 && weatherCode <= 67) {
      return "🌧"; // Yağmurlu
    } else if (weatherCode >= 71 && weatherCode <= 86) {
      return "❄"; // Karlı
    } else if (weatherCode >= 95 && weatherCode <= 99) {
      return "⛈"; // Fırtına
    } else {
      return "☁"; // Bulutlu
    }
  }

  // Ödevleri API'den çekmek için HTTP isteği
  Future<void> fetchUpcomingHomeworks() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/homeworks'));
    if (response.statusCode == 200) {
      List<dynamic> homeworks = json.decode(response.body);
      List<dynamic> filteredHomeworks = homeworks.where((homework) {
        DateTime dueDate = DateTime.parse(homework['teslim_tarihi']);
        return dueDate.isAfter(DateTime.now());
      }).toList();
      filteredHomeworks.sort((a, b) {
        DateTime dueDateA = DateTime.parse(a['teslim_tarihi']);
        DateTime dueDateB = DateTime.parse(b['teslim_tarihi']);
        return dueDateA.compareTo(dueDateB);
      });
      List<dynamic> topFiveHomeworks = filteredHomeworks.take(5).toList();
      setState(() {
        upcomingHomeworks = topFiveHomeworks;
      });
    } else {
      throw Exception('Failed to load homeworks');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchUpcomingHomeworks();
  }

  // Kalan günleri hesaplayan fonksiyon
  String calculateRemainingDays(DateTime dueDate) {
    final Duration difference = dueDate.difference(DateTime.now());
    if (difference.inDays > 0) {
      return '${difference.inDays} Gün Kaldı!';
    } else if (difference.inDays == 0) {
      return 'Bugün Teslim!';
    } else {
      return 'Teslim Tarihi Geçti!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Öğrenci Takip Programı',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Öğretmen Card'ı
                  Center(
                    child: Container(
                      width: 300, // Sabit genişlik
                      height: 320, // Sabit yükseklik
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Color(0xFF7BD5E1), // Pastel mavi border
                            width: 2.5, // Biraz daha kalın border
                          ),
                        ),
                        color: Theme.of(context)
                            .scaffoldBackgroundColor, // Sayfanın arka plan rengi ile aynı
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Hoşgeldin',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      // Koyu metin rengi
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    teacherName ?? 'Yükleniyor...',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(
                                        0xFF7BD5E1), // Profil resmi etrafına da aynı renk border
                                    width: 2,
                                  ),
                                ),
                                child: teacherImage != null
                                    ? CircleAvatar(
                                        radius: 60,
                                        backgroundImage:
                                            NetworkImage(teacherImage!),
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundImage: AssetImage(
                                            'assets/default_avatar.png'),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Yaklaşan Ödevler ve Ayın Öğrencisi Row'u
                  Row(
                    children: [
                      // Yaklaşan Ödevler Card'ı
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 250),
                          child: Container(
                            width: 200, // Sabit genişlik
                            height: 400, // Sabit yükseklik
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Colors.pink.shade200, width: 2),
                              ),
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor, // Sayfanın arka plan rengi ile aynı
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 45, // Sabit yükseklik
                                      width: double.infinity, // Full width
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.pink.shade100,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        'Yaklaşan Ödevler',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (upcomingHomeworks.isEmpty)
                                      Text('Yaklaşan ödev bulunmamaktadır.')
                                    else
                                      ...upcomingHomeworks
                                          .take(3)
                                          .map((homework) {
                                        DateTime dueDate = DateTime.parse(
                                            homework['teslim_tarihi']);
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.assignment,
                                                  color: Colors.pink.shade200,
                                                  size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      homework['odev_adi'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      calculateRemainingDays(
                                                          dueDate),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Ayın Öğrencisi Card'ı
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 250),
                          child: Container(
                            width: 200, // Sabit genişlik
                            height: 400, // Sabit yükseklik
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Colors.purple.shade200, width: 2),
                              ),
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor, // Sayfanın arka plan rengi ile aynı
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 47.5, // Sabit yükseklik
                                    width: double.infinity, // Full width
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12.0, top: 3),
                                      child: Text(
                                        'Ayın Öğrencisi',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.emoji_events,
                                              color: Colors.purple.shade200),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Henüz Belirlenmedi',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  'Analiz devam ediyor...',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Tarih Card'ı - Sağ üst köşede
          GoogleStyleCalendar(),
          _buildEducationYearCard(),
          _buildWeatherCard(), // Hava durumu kartı
        ],
      ),
    );
  }

  Widget _buildEducationYearCard() {
    return Positioned(
      top: 216,
      right: 10, // GoogleStyleCalendar'ın solunda
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEducationYearPage()),
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Color(0xFFFFE0B2),
              width: 2,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school,
                  color: Color(0xFFFFE0B2),
                  size: 24,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Aktif Eğitim-Öğretim Yılı',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      currentYear ?? 'Yükleniyor...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Positioned(
      top: 20, // Eğitim yılı kartının altında
      left: 20, // GoogleStyleCalendar'ın solunda
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Color(0xFF000080), // Lacivert renk
            width: 2,
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/atmospheric-conditions.png',
                width: 32,
                height: 32,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hava Durumu',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    weatherInfo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menü
  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueGrey[600],
            ),
            child: Column(
              children: [
                teacherImage != null
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(teacherImage!),
                      )
                    : CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                            'assets/default_avatar.png'), // Varsayılan resim
                      ),
                SizedBox(height: 10),
                Text(
                  '${teacherName ?? 'Yükleniyor...'}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          buildMenuTile(context, 'Öğretmen', Icons.person_4, [
            'Öğrenci Takip',
          ]),
          buildMenuTile(context, 'Öğrenci', Icons.person, [
            'Öğrenci Bilgileri',
            'Sure ve Dua Takibi',
            'Ödev Kontrol',
            'Öğretmen Görüşü',
            'Defter Kitap Kontrol',
            'Yaramazlık Kontrol',
            "Not Ekranı",
            'KDS Kontrol Ekranı',
            'Deneme Sınavı Ekranı',
            'Okul Deneme Ekranı',
            'Öğrenci Soru Takibi'
          ]),
          buildMenuTile(context, 'Atama İşlemleri', Icons.assignment, [
            'Yıl Atama',
            'Ders Atama',
            'Dua Sure Atama',
            'Ödev Atama',
            'KDS Atama',
            'Deneme Sınavı Atama'
          ]),
          buildMenuTile(context, 'Bilgi Girişi', Icons.input, [
            'Sınıflar',
            'Dersler',
            'Sure ve Dua',
            'Ödev',
            'Görüş Ekle',
            'Yaramazlık',
            'Unite',
            'KDS Ekle',
            'Deneme Sınavı Ekle',
            'Okul Denemesi Ekle',
            'Eğitim Öğretim Yılı Ekle'
          ]),
          buildMenuTile(context, 'Profil', Icons.settings,
              ['Hesabım', 'Sistem Ayarları']),
          buildMenuTile(
              context, 'Hakkında', Icons.info, ['Versiyon Bilgisi', 'Yardım']),
        ],
      ),
    );
  }

  Widget buildMenuTile(
      BuildContext context, String title, IconData icon, List<String> options) {
    // Başlığa göre özel ikon seç
    Widget leadingIcon;
    switch (title) {
      case 'Öğretmen':
        leadingIcon = Image.asset(
          'assets/icons/teacher.png',
          width: 24,
          height: 24,
        );
        break;
      case 'Öğrenci':
        leadingIcon = Image.asset(
          'assets/icons/student.png',
          width: 24,
          height: 24,
        );
        break;
      case 'Atama İşlemleri':
        leadingIcon = Image.asset(
          'assets/icons/assignment.png',
          width: 24,
          height: 24,
        );
        break;
      case 'Bilgi Girişi':
        leadingIcon = Image.asset(
          'assets/icons/data.png',
          width: 24,
          height: 24,
        );
        break;
      case 'Profil':
        leadingIcon = Image.asset(
          'assets/icons/user-account.png',
          width: 24,
          height: 24,
        );
        break;
      case 'Hakkında':
        leadingIcon = Image.asset(
          'assets/icons/about.png',
          width: 24,
          height: 24,
        );
        break;
      default:
        leadingIcon = Icon(icon, color: Colors.blueGrey);
    }

    return ExpansionTile(
      leading: leadingIcon,
      title: Text(title, style: const TextStyle(fontSize: 18.0)),
      children: options.map<Widget>((String choice) {
        return ListTile(
          leading: const Icon(Icons.arrow_right),
          title: Text(choice, style: const TextStyle(fontSize: 16.0)),
          onTap: () {
            Navigator.pop(context);

            // İlgili sayfaya yönlendirme
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
                    builder: (context) => MisbehaviourControlPage()),
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
                MaterialPageRoute(
                    builder: (context) => const TeacherCommentPage()),
              );
            } else if (choice == 'Sure ve Dua') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrayerSurahScreen()),
              );
            } else if (choice == 'Okul Deneme Ekranı') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OgrenciOkulDenemeleriScreen()));
            } else if (choice == 'Dersler') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CourseAddPage()),
              );
            } else if (choice == 'Görüş Ekle') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TeacherFeedbackOptionScreen()),
              );
            } else if (choice == 'Yıl Atama') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BilgiAktarmaPage()),
              );
            } else if (choice == 'Ödev') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeworkScreen()),
              );
            } else if (choice == 'Sure ve Dua Takibi') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrayerSurahTrackingScreen()),
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
                MaterialPageRoute(builder: (context) => ClassAddPage()),
              );
            } else if (choice == 'Ders Atama') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CourseClassAssignPage()),
              );
            } else if (choice == 'Dua Sure Atama') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrayerSurahAssignmentScreen()),
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
                MaterialPageRoute(builder: (context) => MisbehaviourPage()),
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

// FadeIn animasyonu (Animasyon için kullanılabilir)
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

    // Delay the start of the animation
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
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
      child: widget.child,
    );
  }
}
