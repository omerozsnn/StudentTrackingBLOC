// lib/blocs/student/student_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_repository.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository repository;
  String? selectedClass;
  List<Student> students = [];
  Student? selectedStudent;
  bool _shownPhotoError404 = false;

  StudentBloc({required this.repository}) : super(StudentInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<LoadStudentsByClass>(_onLoadStudentsByClass);
    on<SearchStudents>(_onSearchStudents);
    on<SelectStudent>(_onSelectStudent);
    on<LoadStudentDetails>(_onLoadStudentDetails);
    on<DeleteStudent>(_onDeleteStudent);
    on<UploadStudentPhoto>(_onUploadStudentPhoto);
    on<GetStudentPhoto>(_onGetStudentPhoto);
    on<StudentLoadingEvent>(_onStudentLoading);
    on<AddStudent>(_onAddStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<ImportStudentsFromExcel>(_onImportStudentsFromExcel);
    on<UpdateStudentsFromExcel>(_onUpdateStudentsFromExcel);
  }

  Future<void> _onLoadStudents(
      LoadStudents event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      final result = await repository.getStudents();
      students = result['data'] as List<Student>;
      emit(StudentsLoaded(students));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadStudentsByClass(
      LoadStudentsByClass event, Emitter<StudentState> emit) async {
    // Eğer zaten aynı sınıf seçili ise ve öğrenciler yüklü ise tekrar yükleme yapma
    if (selectedClass == event.className && students.isNotEmpty) {
      emit(StudentsLoaded(students));
      return;
    }

    // Önce Loading durumunu yayınla
    emit(StudentLoading());
    try {
      print('Sınıfa göre öğrenciler yükleniyor: ${event.className}');
      selectedClass = event.className;
      students = await repository.getStudentsByClassName(event.className);
      print('Sınıfta ${students.length} öğrenci bulundu');

      // Öğrencilerin fotoğraflarını yüklemeden, sadece liste bilgisini tut
      // Fotoğraflar, StudentListItem widget'ı tarafından lazım oldukça yüklenecek
      final loadedState = StudentsLoaded(students);
      emit(loadedState);

      if (students.isEmpty) {
        // Eğer liste boşsa bilgi mesajı göster fakat StudentsLoaded durumunu değiştirme
        emit(StudentOperationMessage(
            '${event.className} sınıfında şu an için öğrenci bulunmuyor.'));
        // StudentsLoaded durumuna tekrar dön, böylece bilgi mesajı geçici olur
        emit(loadedState);
      }
    } catch (e) {
      print('Sınıfa göre öğrenciler yüklenemedi: $e');
      // Hatayı göster
      emit(StudentError('Öğrenciler yüklenirken hata oluştu: $e'));
      // Yine de en son liste durumunu koruyalım
      if (students.isNotEmpty) {
        emit(StudentsLoaded(students));
      } else {
        // Eğer hiç öğrenci yoksa boş liste ile yüklü durumuna geç
        emit(StudentsLoaded([]));
      }
    }
  }

  Future<void> _onSearchStudents(
      SearchStudents event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      students = await repository.searchStudents(event.query);
      emit(StudentsLoaded(students));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onSelectStudent(
      SelectStudent event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      final student = await repository.getStudentById(event.studentId);
      selectedStudent = student;
      emit(StudentSelected(student, students));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadStudentDetails(
      LoadStudentDetails event, Emitter<StudentState> emit) async {
    // First emit loading state
    emit(StudentLoading());

    try {
      debugPrint("Loading student details for ID: ${event.studentId}");

      // Use the modified getStudentWithImage that handles missing images gracefully
      final student = await repository.getStudentWithImage(event.studentId);

      // Update the selected student in the bloc
      selectedStudent = student;

      debugPrint("Student details loaded: ${student.adSoyad}");

      // Emit state with student details (with or without image)
      emit(StudentSelected(student, students));

      // If we have photo data, also emit a photo loaded state
      if (student.photoData != null) {
        debugPrint("Student photo loaded: ${student.photoData!.length} bytes");
        emit(StudentPhotoLoaded(event.studentId, student.photoData!));
      } else {
        debugPrint("Student loaded without image for ID: ${event.studentId}");
      }
    } catch (e) {
      // This is a critical error - the student data itself couldn't be loaded
      debugPrint("Öğrenci bilgileri yüklenemedi: ${e.toString()}");
      emit(StudentError("Öğrenci bilgileri yüklenemedi: ${e.toString()}"));

      // If we have previous student data, make sure to display it
      if (selectedStudent != null) {
        emit(StudentSelected(selectedStudent!, students));
      }
    }
  }

  Future<void> _onDeleteStudent(
      DeleteStudent event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      final success = await repository.deleteStudent(event.studentId);
      if (success) {
        students.removeWhere((student) => student.id == event.studentId);
        selectedStudent = null;
        emit(StudentOperationSuccess('Öğrenci başarıyla silindi.'));
        emit(StudentsLoaded(students));
      } else {
        emit(StudentError('Öğrenci silinemedi.'));
      }
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onUploadStudentPhoto(
      UploadStudentPhoto event, Emitter<StudentState> emit) async {
    try {
      // Fotoğraf yükleme başlamadan önce yükleme durumu bildir
      emit(StudentLoading());

      // Fotoğraf yükleme işlemini gerçekleştir
      final uploadResponse =
          await repository.uploadStudentPhoto(event.studentId, event.photoFile);

      // Başarı mesajını yayınla
      emit(StudentOperationSuccess('Fotoğraf başarıyla yüklendi.'));

      // Eğer şu an seçili olan öğrenci, fotoğrafı yüklenen öğrenci ise
      if (selectedStudent != null && selectedStudent!.id == event.studentId) {
        try {
          // Öğrenciyi güncel detaylarıyla getir
          final updatedStudent =
              await repository.getStudentWithImage(event.studentId);
          selectedStudent = updatedStudent;

          // Öğrenci bilgilerini hemen göster
          emit(StudentSelected(updatedStudent, students));

          // Eğer fotoğraf verisi varsa, ayrıca fotoğraf yüklenme durumunu bildir
          if (updatedStudent.photoData != null) {
            emit(
                StudentPhotoLoaded(event.studentId, updatedStudent.photoData!));
          }
        } catch (studentError) {
          debugPrint(
              "Öğrenci bilgileri yüklenemedi: ${studentError.toString()}");

          // Hata olsa bile mevcut seçili öğrenciyi göstermeye devam et
          if (selectedStudent != null) {
            emit(StudentSelected(selectedStudent!, students));
          }

          // Kullanıcıya hata mesajı göster
          emit(StudentOperationMessage(
              "Fotoğraf yüklendi, ancak öğrenci bilgileri güncellenemedi."));
        }
      } else {
        // Öğrenci listesini mevcut durumda göster
        emit(StudentsLoaded(students));
      }
    } catch (e) {
      debugPrint("Fotoğraf yükleme hatası: ${e.toString()}");
      emit(StudentError("Fotoğraf yüklenemedi: ${e.toString()}"));

      // Hata durumunda, eğer bir öğrenci seçili ise onu tekrar göster
      if (selectedStudent != null) {
        emit(StudentSelected(selectedStudent!, students));
      } else {
        // Öğrenci seçili değilse, öğrenci listesini göster
        emit(StudentsLoaded(students));
      }
    }
  }

  Future<void> _onGetStudentPhoto(
      GetStudentPhoto event, Emitter<StudentState> emit) async {
    try {
      final photo = await repository.getStudentPhoto(event.studentId);
      if (photo != null) {
        debugPrint(
            "Photo loaded for student ID: ${event.studentId}, size: ${photo.length} bytes");
        emit(StudentPhotoLoaded(event.studentId, photo));
      } else {
        // Fotoğraf bulunamadığında sessizce geç, hata veya mesaj gösterme
        // Fallback avatar zaten UI tarafında görüntülenecek
        debugPrint("No photo found for student ID: ${event.studentId}");
      }
    } catch (e) {
      // Hiçbir hata mesajı gösterme, sadece loglama yap
      debugPrint("Öğrenci fotoğrafı yüklenemedi: ${e.toString()}");

      // Hata durumunda herhangi bir state değişikliği yapmıyoruz
      // Bu sayede öğrenci listesi kesintisiz yüklenmeye devam eder
    }
  }

  // Yükleme durumu için basit bir handler
  void _onStudentLoading(
      StudentLoadingEvent event, Emitter<StudentState> emit) {
    emit(StudentLoading());
  }

  // Öğrenci ekleme işlemi için handler
  Future<void> _onAddStudent(
      AddStudent event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      // Öğrenci verilerini ekle
      final newStudent = await repository.addStudent(event.studentData);

      // Başarı mesajını yayınla
      emit(StudentOperationSuccess(
          'Öğrenci başarıyla eklendi: ${newStudent.adSoyad}'));

      // Eğer sınıf seçili ise, o sınıfın öğrencilerini yeniden yükle
      if (selectedClass != null) {
        students = await repository.getStudentsByClassName(selectedClass!);
        emit(StudentsLoaded(students));
      } else {
        // Sınıf seçili değilse, tüm öğrencileri yeniden yükle
        final result = await repository.getStudents();
        students = result['data'] as List<Student>;
        emit(StudentsLoaded(students));
      }

      // Eğer resim dosyası varsa, öğrenci fotoğrafını yükle
      if (event.imageFile != null) {
        await repository.uploadStudentPhoto(newStudent.id, event.imageFile!);
      }
    } catch (e) {
      debugPrint("Öğrenci ekleme hatası: ${e.toString()}");
      emit(StudentError("Öğrenci eklenemedi: ${e.toString()}"));
    }
  }

  // Öğrenci güncelleme işlemi için handler
  Future<void> _onUpdateStudent(
      UpdateStudent event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      // Öğrenci verilerini güncelle
      final updatedStudent =
          await repository.updateStudent(event.studentId, event.updateData);

      // Öğrenci listesindeki ilgili öğrenciyi güncelle
      final studentIndex = students.indexWhere((s) => s.id == event.studentId);
      if (studentIndex >= 0) {
        students[studentIndex] = updatedStudent;
      }

      // Seçili öğrenciyse güncelle
      if (selectedStudent != null && selectedStudent!.id == event.studentId) {
        selectedStudent = updatedStudent;
      }

      // Eğer resim dosyası varsa, öğrenci fotoğrafını yükle
      if (event.imageFile != null) {
        await repository.uploadStudentPhoto(event.studentId, event.imageFile!);

        // Fotoğraf yüklemeden sonra güncel öğrenci bilgilerini al
        final studentWithPhoto =
            await repository.getStudentWithImage(event.studentId);

        // Öğrenci listesindeki ve seçili öğrencideki fotoğrafı güncelle
        if (studentIndex >= 0) {
          students[studentIndex] = studentWithPhoto;
        }
        if (selectedStudent != null && selectedStudent!.id == event.studentId) {
          selectedStudent = studentWithPhoto;
        }
      }

      // Başarı mesajını yayınla
      emit(StudentOperationSuccess('Öğrenci başarıyla güncellendi.'));

      // Güncel durumu yayınla
      if (selectedStudent != null && selectedStudent!.id == event.studentId) {
        emit(StudentSelected(selectedStudent!, students));
      } else {
        emit(StudentsLoaded(students));
      }
    } catch (e) {
      debugPrint("Öğrenci güncelleme hatası: ${e.toString()}");
      emit(StudentError("Öğrenci güncellenemedi: ${e.toString()}"));
    }
  }

  // Excel'den öğrenci içe aktarma işlemi için handler
  Future<void> _onImportStudentsFromExcel(
      ImportStudentsFromExcel event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      // Excel dosyasından öğrencileri içe aktar
      final success = await repository.importStudentsFromExcel(event.excelFile);

      if (success) {
        // Başarı mesajını yayınla
        emit(StudentOperationSuccess(
            'Öğrenciler başarıyla Excel\'den içe aktarıldı!'));

        // Öğrenci listesini yeniden yükle
        if (selectedClass != null) {
          students = await repository.getStudentsByClassName(selectedClass!);
        } else {
          final result = await repository.getStudents();
          students = result['data'] as List<Student>;
        }

        emit(StudentsLoaded(students));
      } else {
        emit(StudentError('Excel\'den öğrenci içe aktarılamadı.'));
      }
    } catch (e) {
      debugPrint("Excel'den öğrenci içe aktarma hatası: ${e.toString()}");
      emit(StudentError("Excel'den öğrenci içe aktarılamadı: ${e.toString()}"));
    }
  }

  // Excel'den öğrenci güncelleme işlemi için handler
  Future<void> _onUpdateStudentsFromExcel(
      UpdateStudentsFromExcel event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      // Excel dosyasından öğrencileri güncelle
      final success = await repository.updateStudentsFromExcel(event.excelFile);

      if (success) {
        // Başarı mesajını yayınla
        emit(StudentOperationSuccess(
            'Öğrenciler başarıyla Excel\'den güncellendi!'));

        // Öğrenci listesini yeniden yükle
        if (selectedClass != null) {
          students = await repository.getStudentsByClassName(selectedClass!);
        } else {
          final result = await repository.getStudents();
          students = result['data'] as List<Student>;
        }

        emit(StudentsLoaded(students));
      } else {
        emit(StudentError('Excel\'den öğrenci güncellenemedi.'));
      }
    } catch (e) {
      debugPrint("Excel'den öğrenci güncelleme hatası: ${e.toString()}");
      emit(StudentError("Excel'den öğrenci güncellenemedi: ${e.toString()}"));
    }
  }
}
