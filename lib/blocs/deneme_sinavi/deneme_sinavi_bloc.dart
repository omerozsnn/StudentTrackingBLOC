import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_repository.dart';
import 'package:ogrenci_takip_sistemi/models/deneme_sinavi_model.dart';

class DenemeSinaviBloc extends Bloc<DenemeSinaviEvent, DenemeSinaviState> {
  final DenemeSinaviRepository repository;
  List<DenemeSinavi> denemeSinavlari = [];
  DenemeSinavi? selectedDenemeSinavi;

  DenemeSinaviBloc({required this.repository}) : super(DenemeSinaviInitial()) {
    on<LoadDenemeSinavlari>(_onLoadDenemeSinavlari);
    on<LoadDenemeSinavlariWithPagination>(_onLoadDenemeSinavlariWithPagination);
    on<LoadDenemeSinavlariByUnit>(_onLoadDenemeSinavlariByUnit);
    on<SearchDenemeSinavlari>(_onSearchDenemeSinavlari);
    on<SelectDenemeSinavi>(_onSelectDenemeSinavi);
    on<AddDenemeSinavi>(_onAddDenemeSinavi);
    on<UpdateDenemeSinavi>(_onUpdateDenemeSinavi);
    on<DeleteDenemeSinavi>(_onDeleteDenemeSinavi);
    on<UploadDenemeSinaviExcel>(_onUploadDenemeSinaviExcel);
    on<DenemeSinaviLoadingEvent>(_onDenemeSinaviLoading);
  }

  Future<void> _onLoadDenemeSinavlari(
      LoadDenemeSinavlari event, Emitter<DenemeSinaviState> emit) async {
    emit(DenemeSinaviLoading());
    try {
      debugPrint("Loading deneme sınavları...");
      final loadedDenemeSinavlari = await repository.getDenemeSinavlari();
      debugPrint("Deneme sınavları loaded: ${loadedDenemeSinavlari.length}");
      denemeSinavlari = loadedDenemeSinavlari;
      emit(DenemeSinavlariLoaded(denemeSinavlari));
    } catch (e) {
      debugPrint("Error loading deneme sınavları: $e");
      emit(DenemeSinaviError(e.toString()));
    }
  }

  Future<void> _onLoadDenemeSinavlariWithPagination(
      LoadDenemeSinavlariWithPagination event, Emitter<DenemeSinaviState> emit) async {
    emit(DenemeSinaviLoading());
    try {
      // Repository'de pagination için metod eklenmesi gerekir
      final loadedDenemeSinavlari = await repository.getDenemeSinavlari();
      denemeSinavlari = loadedDenemeSinavlari;
      emit(DenemeSinavlariLoaded(denemeSinavlari));
    } catch (e) {
      emit(DenemeSinaviError(e.toString()));
    }
  }

  Future<void> _onLoadDenemeSinavlariByUnit(
      LoadDenemeSinavlariByUnit event, Emitter<DenemeSinaviState> emit) async {
    emit(DenemeSinaviLoading());
    try {
      final unitDenemeSinavlari = await repository.getDenemeSinaviByUnit(event.uniteId);
      denemeSinavlari = unitDenemeSinavlari;
      emit(DenemeSinavlariLoaded(denemeSinavlari));
    } catch (e) {
      emit(DenemeSinaviError(e.toString()));
    }
  }

  Future<void> _onSearchDenemeSinavlari(
      SearchDenemeSinavlari event, Emitter<DenemeSinaviState> emit) async {
    emit(DenemeSinaviLoading());
    try {
      // Basit arama işlevi - mevcut listeyi filtrele
      final filteredDenemeSinavlari = denemeSinavlari.where((ds) => 
        ds.denemeSinaviAdi?.toLowerCase().contains(event.query.toLowerCase()) ?? false).toList();
      emit(DenemeSinavlariLoaded(filteredDenemeSinavlari));
    } catch (e) {
      emit(DenemeSinaviError(e.toString()));
    }
  }

  Future<void> _onSelectDenemeSinavi(
      SelectDenemeSinavi event, Emitter<DenemeSinaviState> emit) async {
    if (event.denemeSinavi == null) {
      selectedDenemeSinavi = null;
      emit(DenemeSinavlariLoaded(denemeSinavlari));
      return;
    }

    emit(DenemeSinaviLoading());
    try {
      final denemeSinavi = await repository.getDenemeSinaviById(event.denemeSinavi!.id!);
      selectedDenemeSinavi = denemeSinavi;
      emit(DenemeSinaviSelected(denemeSinavi, denemeSinavlari: denemeSinavlari));
    } catch (e) {
      emit(DenemeSinaviError(e.toString()));
    }
  }

  Future<void> _onAddDenemeSinavi(
      AddDenemeSinavi event, Emitter<DenemeSinaviState> emit) async {
    emit(DenemeSinaviLoading());
    try {
      final newDenemeSinavi = await repository.addDenemeSinavi(event.denemeSinavi);
      denemeSinavlari.add(newDenemeSinavi);
      emit(DenemeSinaviOperationSuccess('Deneme sınavı başarıyla eklendi.', denemeSinavlari: denemeSinavlari));
      emit(DenemeSinavlariLoaded(denemeSinavlari));
    } catch (e) {
      debugPrint("Deneme sınavı ekleme hatası: ${e.toString()}");
      emit(DenemeSinaviError("Deneme sınavı eklenemedi: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateDenemeSinavi(
      UpdateDenemeSinavi event, Emitter<DenemeSinaviState> emit) async {
    emit(DenemeSinaviLoading());
    try {
      final updatedDenemeSinavi = await repository.updateDenemeSinavi(event.denemeSinavi);
      final index = denemeSinavlari.indexWhere((ds) => ds.id == updatedDenemeSinavi.id);
      if (index != -1) {
        denemeSinavlari[index] = updatedDenemeSinavi;
      }
      
      if (selectedDenemeSinavi?.id == updatedDenemeSinavi.id) {
        selectedDenemeSinavi = updatedDenemeSinavi;
      }
      
      emit(DenemeSinaviOperationSuccess('Deneme sınavı başarıyla güncellendi.', 
        denemeSinavlari: denemeSinavlari,
        selectedDenemeSinavi: selectedDenemeSinavi
      ));
      emit(DenemeSinavlariLoaded(denemeSinavlari, selectedDenemeSinavi: selectedDenemeSinavi));
    } catch (e) {
      debugPrint("Deneme sınavı güncelleme hatası: ${e.toString()}");
      emit(DenemeSinaviError("Deneme sınavı güncellenemedi: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteDenemeSinavi(
      DeleteDenemeSinavi event, Emitter<DenemeSinaviState> emit) async {
    emit(DenemeSinaviLoading());
    try {
      final success = await repository.deleteDenemeSinavi(event.denemeSinaviId);
      if (success) {
        denemeSinavlari.removeWhere((ds) => ds.id == event.denemeSinaviId);
        
        if (selectedDenemeSinavi?.id == event.denemeSinaviId) {
          selectedDenemeSinavi = null;
        }
        
        emit(DenemeSinaviOperationSuccess('Deneme sınavı başarıyla silindi.'));
        emit(DenemeSinavlariLoaded(denemeSinavlari));
      } else {
        emit(DenemeSinaviError('Deneme sınavı silinemedi.'));
      }
    } catch (e) {
      emit(DenemeSinaviError(e.toString()));
    }
  }

  Future<void> _onUploadDenemeSinaviExcel(
      UploadDenemeSinaviExcel event, Emitter<DenemeSinaviState> emit) async {
    emit(DenemeSinaviLoading());
    try {
      final success = await repository.importDenemeSinavlariFromExcel(event.file);
      if (success) {
        // Excel import sonrası listeyi yenile
        final loadedDenemeSinavlari = await repository.getDenemeSinavlari();
        denemeSinavlari = loadedDenemeSinavlari;
        
        emit(DenemeSinaviOperationSuccess('Deneme sınavları Excel\'den başarıyla içe aktarıldı.'));
        emit(DenemeSinavlariLoaded(denemeSinavlari));
      } else {
        emit(DenemeSinaviError('Deneme sınavları Excel\'den içe aktarılamadı.'));
      }
    } catch (e) {
      debugPrint("Excel'den deneme sınavı içe aktarma hatası: ${e.toString()}");
      emit(DenemeSinaviError("Excel'den deneme sınavı içe aktarılamadı: ${e.toString()}"));
    }
  }

  void _onDenemeSinaviLoading(DenemeSinaviLoadingEvent event, Emitter<DenemeSinaviState> emit) {
    emit(DenemeSinaviLoading());
  }
} 