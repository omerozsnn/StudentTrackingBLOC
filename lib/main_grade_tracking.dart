import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart' as class_api;
import 'package:ogrenci_takip_sistemi/api.dart/courseClassesApi.dart'
    as course_class_api;
import 'package:ogrenci_takip_sistemi/api.dart/grades_api.dart' as grades_api;
import 'package:ogrenci_takip_sistemi/api.dart/studentControlApi.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/grades/grades_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_repository.dart';
import 'package:ogrenci_takip_sistemi/screens/grades/grade_tracking_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Öğrenci Takip Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ClassBloc>(
            create: (context) {
              final classService =
                  class_api.ApiService(baseUrl: 'http://localhost:3000');
              final classRepository = ClassRepository(apiService: classService);
              final classBloc = ClassBloc(repository: classRepository);
              classBloc.add(LoadClasses());
              return classBloc;
            },
          ),
          BlocProvider<CourseClassBloc>(
            create: (context) {
              final courseClassApi =
                  course_class_api.ApiService(baseUrl: 'http://localhost:3000');
              final courseClassRepo =
                  CourseClassRepository(apiService: courseClassApi);
              return CourseClassBloc(repository: courseClassRepo);
            },
          ),
          BlocProvider<StudentBloc>(
            create: (context) {
              final studentApi =
                  StudentApiService(baseUrl: 'http://localhost:3000');
              final studentRepo = StudentRepository(apiService: studentApi);
              return StudentBloc(repository: studentRepo);
            },
          ),
          BlocProvider<GradesBloc>(
            create: (context) {
              final gradesApi =
                  grades_api.GradesRepository(baseUrl: 'http://localhost:3000');
              final gradesRepo = GradesRepository(apiService: gradesApi);
              final gradesBloc = GradesBloc(repository: gradesRepo);
              return gradesBloc;
            },
          ),
        ],
        child: const GradeTrackingScreen(),
      ),
    );
  }
}
