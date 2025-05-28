import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_repository.dart';
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';

class OgrenciDenemeBloc extends Bloc<OgrenciDenemeEvent, OgrenciDenemeState> {
  final OgrenciDenemeRepository repository;
  List<StudentExamResult> results = [];

  OgrenciDenemeBloc({required this.repository}) : super(OgrenciDenemeInitial()) {
    on<LoadAllOgrenciDenemeResults>(_onLoadAllOgrenciDenemeResults);
    on<LoadOgrenciDenemeResultsByStudent>(_onLoadOgrenciDenemeResultsByStudent);
    on<LoadOgrenciDenemeResultsByExam>(_onLoadOgrenciDenemeResultsByExam);
    on<AddOgrenciDenemeResult>(_onAddOgrenciDenemeResult);
    on<UpdateOgrenciDenemeResult>(_onUpdateOgrenciDenemeResult);
    on<DeleteOgrenciDenemeResult>(_onDeleteOgrenciDenemeResult);
    on<UploadOgrenciDenemeExcel>(_onUploadOgrenciDenemeExcel);
    on<LoadOgrenciDenemeParticipation>(_onLoadOgrenciDenemeParticipation);
    on<LoadClassDenemeAverages>(_onLoadClassDenemeAverages);
    on<OgrenciDenemeLoadingEvent>(_onOgrenciDenemeLoading);
  }

  Future<void> _onLoadAllOgrenciDenemeResults(
      LoadAllOgrenciDenemeResults event, Emitter<OgrenciDenemeState> emit) async {
    emit(OgrenciDenemeLoading());
    try {
      results = await repository.getAllStudentExamResults();
      emit(OgrenciDenemeResultsLoaded(results));
    } catch (e) {
      emit(OgrenciDenemeError(e.toString()));
    }
  }

  Future<void> _onLoadOgrenciDenemeResultsByStudent(
      LoadOgrenciDenemeResultsByStudent event, Emitter<OgrenciDenemeState> emit) async {
    emit(OgrenciDenemeLoading());
    try {
      final studentResults = await repository.getStudentExamResultsByStudentId(event.ogrenciId);
      emit(OgrenciDenemeResultsByStudentLoaded(studentResults, event.ogrenciId));
    } catch (e) {
      emit(OgrenciDenemeError(e.toString()));
    }
  }

  Future<void> _onLoadOgrenciDenemeResultsByExam(
      LoadOgrenciDenemeResultsByExam event, Emitter<OgrenciDenemeState> emit) async {
    emit(OgrenciDenemeLoading());
    try {
      final examResults = await repository.getStudentsScoresByExam(event.denemeSinaviId);
      emit(OgrenciDenemeResultsByExamLoaded(examResults, event.denemeSinaviId));
    } catch (e) {
      emit(OgrenciDenemeError(e.toString()));
    }
  }

  Future<void> _onAddOgrenciDenemeResult(
      AddOgrenciDenemeResult event, Emitter<OgrenciDenemeState> emit) async {
    emit(OgrenciDenemeLoading());
    try {
      await repository.createStudentExamResult(event.result);
      emit(OgrenciDenemeOperationSuccess('Deneme sonucu başarıyla eklendi.'));
      // Listeyi yeniden yükle
      results = await repository.getAllStudentExamResults();
      emit(OgrenciDenemeResultsLoaded(results));
    } catch (e) {
      emit(OgrenciDenemeError(e.toString()));
    }
  }

  Future<void> _onUpdateOgrenciDenemeResult(
      UpdateOgrenciDenemeResult event, Emitter<OgrenciDenemeState> emit) async {
    emit(OgrenciDenemeLoading());
    try {
      await repository.updateStudentExamResult(
        event.ogrenciId, 
        event.denemeSinaviId, 
        event.data
      );
      emit(OgrenciDenemeOperationSuccess('Deneme sonucu başarıyla güncellendi.'));
      // Listeyi yeniden yükle
      results = await repository.getAllStudentExamResults();
      emit(OgrenciDenemeResultsLoaded(results));
    } catch (e) {
      emit(OgrenciDenemeError(e.toString()));
    }
  }

  Future<void> _onDeleteOgrenciDenemeResult(
      DeleteOgrenciDenemeResult event, Emitter<OgrenciDenemeState> emit) async {
    emit(OgrenciDenemeLoading());
    try {
      await repository.deleteStudentExamResult(event.id);
      results.removeWhere((result) => result.id == event.id);
      emit(OgrenciDenemeOperationSuccess('Deneme sonucu başarıyla silindi.'));
      emit(OgrenciDenemeResultsLoaded(results));
    } catch (e) {
      emit(OgrenciDenemeError(e.toString()));
    }
  }

  Future<void> _onUploadOgrenciDenemeExcel(
      UploadOgrenciDenemeExcel event, Emitter<OgrenciDenemeState> emit) async {
    emit(OgrenciDenemeLoading());
    try {
      await repository.importExamPointsFromExcel(event.file);
      emit(OgrenciDenemeOperationSuccess('Excel dosyası başarıyla yüklendi.'));
      // Listeyi yeniden yükle
      results = await repository.getAllStudentExamResults();
      emit(OgrenciDenemeResultsLoaded(results));
    } catch (e) {
      emit(OgrenciDenemeError(e.toString()));
    }
  }

  Future<void> _onLoadOgrenciDenemeParticipation(
      LoadOgrenciDenemeParticipation event, Emitter<OgrenciDenemeState> emit) async {
    emit(OgrenciDenemeLoading());
    try {
      final participation = await repository.getStudentExamParticipation(event.ogrenciId);
      emit(OgrenciDenemeParticipationLoaded(participation));
    } catch (e) {
      emit(OgrenciDenemeError(e.toString()));
    }
  }

  Future<void> _onLoadClassDenemeAverages(
      LoadClassDenemeAverages event, Emitter<OgrenciDenemeState> emit) async {
    emit(OgrenciDenemeLoading());
    try {
      final averages = await repository.getClassDenemeAverages(event.sinifId, event.ogrenciId);
      emit(ClassDenemeAveragesLoaded(averages));
    } catch (e) {
      emit(OgrenciDenemeError(e.toString()));
    }
  }

  void _onOgrenciDenemeLoading(OgrenciDenemeLoadingEvent event, Emitter<OgrenciDenemeState> emit) {
    emit(OgrenciDenemeLoading());
  }
} 