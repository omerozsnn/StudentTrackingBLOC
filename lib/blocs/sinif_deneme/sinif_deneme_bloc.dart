import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_repository.dart';

class SinifDenemeBloc extends Bloc<SinifDenemeEvent, SinifDenemeState> {
  final SinifDenemeRepository repository;
  List<dynamic> sinifDenemeleri = [];
  List<dynamic> examsByClass = [];
  List<dynamic> classesByExam = [];

  SinifDenemeBloc({required this.repository}) : super(SinifDenemeInitial()) {
    on<LoadAllSinifDenemeleri>(_onLoadAllSinifDenemeleri);
    on<LoadExamsByClass>(_onLoadExamsByClass);
    on<LoadClassesByExam>(_onLoadClassesByExam);
    on<CreateSinifDeneme>(_onCreateSinifDeneme);
    on<UpdateSinifDeneme>(_onUpdateSinifDeneme);
    on<DeleteSinifDeneme>(_onDeleteSinifDeneme);
    on<AssignExamToClass>(_onAssignExamToClass);
    on<AssignExamToFifthGrade>(_onAssignExamToFifthGrade);
    on<AssignExamToSixthGrade>(_onAssignExamToSixthGrade);
    on<AssignExamToSeventhGrade>(_onAssignExamToSeventhGrade);
    on<AssignExamToEighthGrade>(_onAssignExamToEighthGrade);
    on<SinifDenemeLoadingEvent>(_onSinifDenemeLoading);
  }

  Future<void> _onLoadAllSinifDenemeleri(
      LoadAllSinifDenemeleri event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      sinifDenemeleri = await repository.getAllSinifDenemeleri();
      emit(SinifDenemeleriLoaded(sinifDenemeleri));
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onLoadExamsByClass(
      LoadExamsByClass event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      debugPrint("Loading exams for class ID: ${event.sinifId}");
      examsByClass = await repository.getExamsByClass(event.sinifId);
      debugPrint("Loaded ${examsByClass.length} exams for class ID: ${event.sinifId}");
      emit(ExamsByClassLoaded(examsByClass, event.sinifId));
    } catch (e) {
      debugPrint("Error loading exams for class: $e");
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onLoadClassesByExam(
      LoadClassesByExam event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      classesByExam = await repository.getClassesByExam(event.denemeSinaviId);
      emit(ClassesByExamLoaded(classesByExam, event.denemeSinaviId));
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onCreateSinifDeneme(
      CreateSinifDeneme event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      await repository.createSinifDenemeleri(event.data);
      emit(SinifDenemeOperationSuccess('Sınıf ve deneme sınavı başarıyla ilişkilendirildi.'));
      // Listeyi yeniden yükle
      sinifDenemeleri = await repository.getAllSinifDenemeleri();
      emit(SinifDenemeleriLoaded(sinifDenemeleri));
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onUpdateSinifDeneme(
      UpdateSinifDeneme event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      await repository.updateSinifDenemeleri(
        event.sinifId,
        event.denemeSinaviId,
        event.data
      );
      emit(SinifDenemeOperationSuccess('Sınıf-deneme ilişkisi başarıyla güncellendi.'));
      // Listeyi yeniden yükle
      sinifDenemeleri = await repository.getAllSinifDenemeleri();
      emit(SinifDenemeleriLoaded(sinifDenemeleri));
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onDeleteSinifDeneme(
      DeleteSinifDeneme event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      await repository.deleteSinifDenemeleri(event.sinifId, event.denemeSinaviId);
      emit(SinifDenemeOperationSuccess('Sınıf-deneme ilişkisi başarıyla silindi.'));
      // Listeyi yeniden yükle
      sinifDenemeleri = await repository.getAllSinifDenemeleri();
      emit(SinifDenemeleriLoaded(sinifDenemeleri));
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onAssignExamToClass(
      AssignExamToClass event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      await repository.assignExamToSpecificClass(event.examId, event.classId);
      emit(SinifDenemeOperationSuccess('Deneme sınavı başarıyla sınıfa atandı.'));
      
      // İlgili sınıfa ait deneme sınavları listesini güncelle
      if (examsByClass.isNotEmpty) {
        examsByClass = await repository.getExamsByClass(event.classId);
        emit(ExamsByClassLoaded(examsByClass, event.classId));
      }
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onAssignExamToFifthGrade(
      AssignExamToFifthGrade event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      await repository.assignExamToFifthGrade(event.data);
      emit(SinifDenemeOperationSuccess('Deneme sınavı başarıyla 5. sınıflara atandı.'));
      // Global listeyi yeniden yükle
      sinifDenemeleri = await repository.getAllSinifDenemeleri();
      emit(SinifDenemeleriLoaded(sinifDenemeleri));
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onAssignExamToSixthGrade(
      AssignExamToSixthGrade event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      await repository.assignExamToSixthGrade(event.data);
      emit(SinifDenemeOperationSuccess('Deneme sınavı başarıyla 6. sınıflara atandı.'));
      // Global listeyi yeniden yükle
      sinifDenemeleri = await repository.getAllSinifDenemeleri();
      emit(SinifDenemeleriLoaded(sinifDenemeleri));
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onAssignExamToSeventhGrade(
      AssignExamToSeventhGrade event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      await repository.assignExamToSeventhGrade(event.data);
      emit(SinifDenemeOperationSuccess('Deneme sınavı başarıyla 7. sınıflara atandı.'));
      // Global listeyi yeniden yükle
      sinifDenemeleri = await repository.getAllSinifDenemeleri();
      emit(SinifDenemeleriLoaded(sinifDenemeleri));
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  Future<void> _onAssignExamToEighthGrade(
      AssignExamToEighthGrade event, Emitter<SinifDenemeState> emit) async {
    emit(SinifDenemeLoading());
    try {
      await repository.assignExamToEighthGrade(event.data);
      emit(SinifDenemeOperationSuccess('Deneme sınavı başarıyla 8. sınıflara atandı.'));
      // Global listeyi yeniden yükle
      sinifDenemeleri = await repository.getAllSinifDenemeleri();
      emit(SinifDenemeleriLoaded(sinifDenemeleri));
    } catch (e) {
      emit(SinifDenemeError(e.toString()));
    }
  }

  void _onSinifDenemeLoading(SinifDenemeLoadingEvent event, Emitter<SinifDenemeState> emit) {
    emit(SinifDenemeLoading());
  }
} 