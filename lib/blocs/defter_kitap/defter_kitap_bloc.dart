import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/defter_kitap/defter_kitap_repository.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:flutter/foundation.dart';

class DefterKitapBloc extends Bloc<DefterKitapEvent, DefterKitapState> {
  final DefterKitapRepository repository;

  // Student ID'lerine göre defter ve kitap durumlarını saklayacağımız Map'ler
  final Map<int, bool> _studentNotebooks = {};
  final Map<int, bool> _studentBooks = {};

  // Getter metotları
  bool getStudentNotebookStatus(int studentId) =>
      _studentNotebooks[studentId] ?? true;
  bool getStudentBookStatus(int studentId) => _studentBooks[studentId] ?? true;

  // Setter metotları
  void setStudentNotebookStatus(int studentId, bool value) =>
      _studentNotebooks[studentId] = value;
  void setStudentBookStatus(int studentId, bool value) =>
      _studentBooks[studentId] = value;

  DefterKitapBloc({required this.repository}) : super(DefterKitapInitial()) {
    on<LoadDefterKitapDates>(_onLoadDefterKitapDates);
    on<LoadDefterKitapByDate>(_onLoadDefterKitapByDate);
    on<AddOrUpdateDefterKitap>(_onAddOrUpdateDefterKitap);
    on<UpdateStudentDefterKitap>(_onUpdateStudentDefterKitap);
    on<DefterKitapLoading>(_onDefterKitapLoading);
    on<ResetDefterKitapState>(_onResetDefterKitapState);
  }

  Future<void> _onLoadDefterKitapDates(
      LoadDefterKitapDates event, Emitter<DefterKitapState> emit) async {
    emit(DefterKitapLoadingState());
    try {
      final availableDates =
          await repository.getDatesByCourseClassId(event.courseClassId);
      emit(DefterKitapDatesLoaded(availableDates, event.courseClassId));
    } catch (error) {
      // 404 hatası geldiğinde, bu normal bir durum - sadece kayıtlı tarih yok
      if (error.toString().contains('404')) {
        print('Tarih bulunamadı (normal durum): ${error.toString()}');
        // Boş liste ile başarılı bir durum dön
        emit(DefterKitapDatesLoaded([], event.courseClassId));
      } else {
        emit(DefterKitapError('Tarihler yüklenemedi: $error'));
      }
    }
  }

  Future<void> _onLoadDefterKitapByDate(
      LoadDefterKitapByDate event, Emitter<DefterKitapState> emit) async {
    emit(DefterKitapLoadingState());
    try {
      // Convert date format if needed (from DD-MM-YYYY to YYYY-MM-DD)
      String apiDate = event.date;
      if (event.date.contains('-')) {
        final parts = event.date.split('-');
        if (parts.length == 3 && parts[0].length == 2) {
          // DD-MM-YYYY format
          apiDate = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      // Önce sınıf adını al
      final String className =
          await _getClassNameByCourseClassId(event.courseClassId);
      print("Öğrenci listesini getirmek için sınıf adı: $className");

      // Sınıf öğrencilerini al
      List<Student> students =
          await repository.getStudentsByClassName(className);
      print("${students.length} öğrenci bulundu");

      // Kayıtları al
      try {
        final records = await repository.getDefterKitapByDateAndCourseClass(
            apiDate, event.courseClassId);

        // Öğrenci defter ve kitap durumlarını güncelle
        _updateStudentsWithRecords(students, records);

        emit(DefterKitapRecordsLoaded(
            records, event.date, event.courseClassId, students));
      } catch (recordError) {
        print('Kayıtlar alınırken hata: $recordError');

        // Kayıtlarda hata olsa bile öğrenci listesini göster
        // Extension yönteminde sorun olduğu için sadece listeleri temizliyoruz
        _studentNotebooks.clear();
        _studentBooks.clear();

        // Tüm öğrencileri varsayılan olarak TRUE değeriyle set et
        for (final student in students) {
          _studentNotebooks[student.id] = true;
          _studentBooks[student.id] = true;
        }

        // Boş kayıt listesi ile devam et
        emit(DefterKitapRecordsLoaded(
            [], event.date, event.courseClassId, students));
      }
    } catch (error) {
      print('_onLoadDefterKitapByDate hata: $error');
      emit(DefterKitapError('Kayıtlar yüklenemedi: $error'));
    }
  }

  // Helper method to update students list with records data
  void _updateStudentsWithRecords(
      List<Student> students, List<Map<String, dynamic>> records) {
    // Reset all students to default values
    _studentNotebooks.clear();
    _studentBooks.clear();

    // First set all students to default values (they brought their books/notebooks)
    for (final student in students) {
      _studentNotebooks[student.id] = true;
      _studentBooks[student.id] = true;
    }

    // Then update students that have records
    for (final record in records) {
      if (record['students'] != null &&
          record['students'] is List &&
          record['students'].isNotEmpty) {
        final studentId = record['students'][0]['id'] as int;

        // Update our maps with the status
        _studentNotebooks[studentId] = record['defter_durum'] == 'getirdi';
        _studentBooks[studentId] = record['kitap_durum'] == 'getirdi';
      }
    }
  }

  Future<void> _onAddOrUpdateDefterKitap(
      AddOrUpdateDefterKitap event, Emitter<DefterKitapState> emit) async {
    emit(DefterKitapLoadingState());
    try {
      await repository
          .addOrUpdateMultipleDefterKitap(event.defterKitapDataList);

      // Get updated dates list
      final updatedDates =
          await repository.getDatesByCourseClassId(event.courseClassId);

      emit(DefterKitapOperationSuccess('Kontroller başarıyla kaydedildi',
          updatedDates: updatedDates));

      // Reload records for the date
      String apiDate = event.date;
      if (event.date.contains('-')) {
        final parts = event.date.split('-');
        if (parts.length == 3 && parts[0].length == 2) {
          // DD-MM-YYYY format
          apiDate = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      final records = await repository.getDefterKitapByDateAndCourseClass(
          apiDate, event.courseClassId);

      // Load the students for the class
      final String className =
          await _getClassNameByCourseClassId(event.courseClassId);
      final List<Student> students =
          await repository.getStudentsByClassName(className);

      // Update student notebook and book status based on records
      _updateStudentsWithRecords(students, records);

      emit(DefterKitapRecordsLoaded(
          records, event.date, event.courseClassId, students));
    } catch (error) {
      emit(DefterKitapError('Kayıtlar güncellenemedi: $error'));
    }
  }

  Future<void> _onUpdateStudentDefterKitap(
      UpdateStudentDefterKitap event, Emitter<DefterKitapState> emit) async {
    emit(DefterKitapLoadingState());
    try {
      // Convert date format if needed
      String apiDate = event.date;
      if (event.date.contains('-')) {
        final parts = event.date.split('-');
        if (parts.length == 3 && parts[0].length == 2) {
          // DD-MM-YYYY format
          apiDate = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      // Create data for the API
      final Map<String, dynamic> defterKitapData = {
        'ogrenci_id': event.studentId,
        'sinif_dersleri_id': event.courseClassId,
        'defter_durum': event.notebookStatus ? 'getirdi' : 'getirmedi',
        'kitap_durum': event.bookStatus ? 'getirdi' : 'getirmedi',
        'tarih': apiDate,
      };

      await repository.addOrUpdateDefterKitap(defterKitapData);

      // Update our local maps immediately
      _studentNotebooks[event.studentId] = event.notebookStatus;
      _studentBooks[event.studentId] = event.bookStatus;

      // Get current state and update it
      if (state is DefterKitapRecordsLoaded) {
        final currentState = state as DefterKitapRecordsLoaded;

        // Reload dates to get updated list
        final updatedDates =
            await repository.getDatesByCourseClassId(event.courseClassId);

        // Reload records for the date
        final records = await repository.getDefterKitapByDateAndCourseClass(
            apiDate, event.courseClassId);

        // Emit updated records with the same students list and updated status
        emit(DefterKitapRecordsLoaded(
            records, event.date, event.courseClassId, currentState.students));

        // Also emit success state for notification purposes
        emit(DefterKitapOperationSuccess('Kayıt güncellendi',
            updatedDates: updatedDates));
      } else {
        // If we're not in the right state, reload everything
        add(LoadDefterKitapByDate(event.date, event.courseClassId));
      }
    } catch (error) {
      print('Kayıt güncellenirken hata: $error');
      emit(DefterKitapError('Kayıt güncellenemedi: $error'));

      // Error durumunda bile UI'da checkbox durumunu yansıt
      if (state is DefterKitapRecordsLoaded) {
        final currentState = state as DefterKitapRecordsLoaded;
        emit(DefterKitapRecordsLoaded(
          currentState.records,
          currentState.date,
          currentState.courseClassId,
          currentState.students,
        ));
      }
    }
  }

  void _onDefterKitapLoading(
      DefterKitapLoading event, Emitter<DefterKitapState> emit) {
    emit(DefterKitapLoadingState());
  }

  void _onResetDefterKitapState(
      ResetDefterKitapState event, Emitter<DefterKitapState> emit) {
    emit(DefterKitapInitial());
  }

  // Helper method to get class name by course class ID
  Future<String> _getClassNameByCourseClassId(int courseClassId) async {
    try {
      // Use the repository to get the class name from the course class id
      final courseClasses =
          await repository.defterKitapApi.getCourseClassById(courseClassId);

      if (courseClasses != null && courseClasses['class'] != null) {
        // API'den gelen sınıf adını dön - veritabanında '6 A' formatında
        return courseClasses['class']['sinif_adi'] ?? '';
      }

      // Eğer courseClasses API'si çalışmıyorsa, varsayılan sınıf adı döndür
      // NOT: API'nin beklediği format '6 A' şeklinde (tire değil boşluk ile ayrılmış)
      return "6 A";
    } catch (e) {
      print('Sınıf adı alınamadı: $e');
      return "6 A"; // Hata durumunda varsayılan sınıf adı - boşluklu format
    }
  }
}
