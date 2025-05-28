import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:ogrenci_takip_sistemi/models/kds_class_model.dart';
import 'kds_class_event.dart';
import 'kds_class_state.dart';
import 'kds_class_repository.dart';

class KdsClassBloc extends Bloc<KdsClassEvent, KdsClassState> {
  final KdsClassRepository repository;
  List<KdsClass> assignedKdsList = [];

  KdsClassBloc({required this.repository}) : super(const KdsClassInitial()) {
    on<LoadKdsByClass>(_onLoadKdsByClass);
    on<AssignKdsToClass>(_onAssignKdsToClass);
    on<AssignKdsToSixthGrade>(_onAssignKdsToSixthGrade);
    on<AssignKdsToSeventhGrade>(_onAssignKdsToSeventhGrade);
    on<AssignKdsToEighthGrade>(_onAssignKdsToEighthGrade);
    on<AssignMultipleKdsToClasses>(_onAssignMultipleKdsToClasses);
    on<DeleteKdsFromClass>(_onDeleteKdsFromClass);
    on<KdsClassLoadingEvent>(_onKdsClassLoading);
  }

  Future<void> _onLoadKdsByClass(
      LoadKdsByClass event, Emitter<KdsClassState> emit) async {
    emit(KdsClassLoading(assignedKdsList: assignedKdsList));
    try {
      final loadedKdsList = await repository.getKDSByClass(event.classId);
      assignedKdsList = loadedKdsList;
      emit(KdsAssignedListLoaded(assignedKdsList));
    } catch (e) {
      debugPrint("KDS sınıf listesi yüklenirken hata: $e");
      emit(KdsClassError(e.toString(), assignedKdsList: assignedKdsList));
    }
  }

  Future<void> _onAssignKdsToClass(
      AssignKdsToClass event, Emitter<KdsClassState> emit) async {
    emit(KdsClassLoading(assignedKdsList: assignedKdsList));
    try {
      final result =
          await repository.assignKDSClass(event.kdsId, event.classId);
      assignedKdsList = [...assignedKdsList, result];
      emit(KdsClassOperationSuccess(
        'KDS başarıyla sınıfa atandı.',
        assignedKdsList: assignedKdsList,
      ));
    } catch (e) {
      debugPrint("KDS sınıfa atanırken hata: $e");
      emit(KdsClassError(e.toString(), assignedKdsList: assignedKdsList));
    }
  }

  Future<void> _onAssignKdsToSixthGrade(
      AssignKdsToSixthGrade event, Emitter<KdsClassState> emit) async {
    emit(KdsClassLoading(assignedKdsList: assignedKdsList));
    try {
      final success = await repository.assignKDSToSixthGrade(event.kdsId);
      if (success) {
        emit(KdsClassOperationSuccess(
          'KDS başarıyla 6. sınıf seviyesine atandı.',
          assignedKdsList: assignedKdsList,
        ));
      } else {
        emit(KdsClassError('KDS 6. sınıf seviyesine atanamadı.',
            assignedKdsList: assignedKdsList));
      }
    } catch (e) {
      debugPrint("KDS 6. sınıf seviyesine atanırken hata: $e");
      emit(KdsClassError(e.toString(), assignedKdsList: assignedKdsList));
    }
  }

  Future<void> _onAssignKdsToSeventhGrade(
      AssignKdsToSeventhGrade event, Emitter<KdsClassState> emit) async {
    emit(KdsClassLoading(assignedKdsList: assignedKdsList));
    try {
      final success = await repository.assignKDSToSeventhGrade(event.kdsId);
      if (success) {
        emit(KdsClassOperationSuccess(
          'KDS başarıyla 7. sınıf seviyesine atandı.',
          assignedKdsList: assignedKdsList,
        ));
      } else {
        emit(KdsClassError('KDS 7. sınıf seviyesine atanamadı.',
            assignedKdsList: assignedKdsList));
      }
    } catch (e) {
      debugPrint("KDS 7. sınıf seviyesine atanırken hata: $e");
      emit(KdsClassError(e.toString(), assignedKdsList: assignedKdsList));
    }
  }

  Future<void> _onAssignKdsToEighthGrade(
      AssignKdsToEighthGrade event, Emitter<KdsClassState> emit) async {
    emit(KdsClassLoading(assignedKdsList: assignedKdsList));
    try {
      final success = await repository.assignKDSToEighthGrade(event.kdsId);
      if (success) {
        emit(KdsClassOperationSuccess(
          'KDS başarıyla 8. sınıf seviyesine atandı.',
          assignedKdsList: assignedKdsList,
        ));
      } else {
        emit(KdsClassError('KDS 8. sınıf seviyesine atanamadı.',
            assignedKdsList: assignedKdsList));
      }
    } catch (e) {
      debugPrint("KDS 8. sınıf seviyesine atanırken hata: $e");
      emit(KdsClassError(e.toString(), assignedKdsList: assignedKdsList));
    }
  }

  Future<void> _onAssignMultipleKdsToClasses(
      AssignMultipleKdsToClasses event, Emitter<KdsClassState> emit) async {
    emit(KdsClassLoading(assignedKdsList: assignedKdsList));
    try {
      bool allSuccessful = true;
      String errorMessage = '';

      for (int kdsId in event.kdsIds) {
        try {
          if (event.isClassLevelSelected) {
            // Sınıf seviyesine göre atama
            if (event.classLevel == null) {
              throw Exception('Lütfen bir sınıf seviyesi seçin');
            }

            bool success = false;
            if (event.classLevel == "6") {
              success = await repository.assignKDSToSixthGrade(kdsId);
            } else if (event.classLevel == "7") {
              success = await repository.assignKDSToSeventhGrade(kdsId);
            } else if (event.classLevel == "8") {
              success = await repository.assignKDSToEighthGrade(kdsId);
            } else if (event.classLevel == "5") {
              throw Exception(
                  '5. sınıflar için KDS atama fonksiyonu tanımlanmamış.');
            }

            if (!success) {
              allSuccessful = false;
              errorMessage = 'Bazı KDS\'ler atanamadı.';
              break;
            }
          } else {
            // Belirli sınıfa göre atama
            if (event.classId == null) {
              throw Exception('Lütfen bir sınıf seçin');
            }
            await repository.assignKDSClass(kdsId, event.classId!);
          }
        } catch (e) {
          allSuccessful = false;
          errorMessage = e.toString();
          break;
        }
      }

      if (allSuccessful) {
        emit(KdsClassOperationSuccess(
          '${event.kdsIds.length} adet KDS başarıyla atandı.',
          assignedKdsList: assignedKdsList,
        ));
      } else {
        emit(KdsClassError(errorMessage, assignedKdsList: assignedKdsList));
      }
    } catch (e) {
      debugPrint("Çoklu KDS atanırken hata: $e");
      emit(KdsClassError(e.toString(), assignedKdsList: assignedKdsList));
    }
  }

  Future<void> _onDeleteKdsFromClass(
      DeleteKdsFromClass event, Emitter<KdsClassState> emit) async {
    emit(KdsClassLoading(assignedKdsList: assignedKdsList));
    try {
      final success =
          await repository.deleteKDSFromClass(event.kdsId, event.classId);
      if (success) {
        assignedKdsList.removeWhere(
            (kds) => kds.kdsId == event.kdsId && kds.classId == event.classId);
        emit(KdsClassOperationSuccess(
          'KDS başarıyla sınıftan kaldırıldı.',
          assignedKdsList: assignedKdsList,
        ));
      } else {
        emit(KdsClassError('KDS sınıftan kaldırılamadı.',
            assignedKdsList: assignedKdsList));
      }
    } catch (e) {
      debugPrint("KDS sınıftan kaldırılırken hata: $e");
      emit(KdsClassError(e.toString(), assignedKdsList: assignedKdsList));
    }
  }

  void _onKdsClassLoading(
      KdsClassLoadingEvent event, Emitter<KdsClassState> emit) {
    emit(KdsClassLoading(assignedKdsList: assignedKdsList));
  }
}
