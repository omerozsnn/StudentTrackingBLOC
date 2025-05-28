import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_repository.dart';
import 'package:ogrenci_takip_sistemi/models/units_model.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  final UnitRepository repository;
  List<Unit> units = [];
  Unit? selectedUnit;

  UnitBloc({required this.repository}) : super(UnitInitial()) {
    on<LoadUnits>(_onLoadUnits);
    on<LoadUnitsWithPagination>(_onLoadUnitsWithPagination);
    on<SearchUnits>(_onSearchUnits);
    on<SelectUnit>(_onSelectUnit);
    on<AddUnit>(_onAddUnit);
    on<UpdateUnit>(_onUpdateUnit);
    on<DeleteUnit>(_onDeleteUnit);
    on<UploadUnitExcel>(_onUploadUnitExcel);
    on<UnitLoadingEvent>(_onUnitLoading);
  }

  Future<void> _onLoadUnits(
      LoadUnits event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      debugPrint("Loading units...");
      final loadedUnits = await repository.getUnits();
      debugPrint("Units loaded: ${loadedUnits.length}");
      units = loadedUnits;
      emit(UnitsLoaded(units));
    } catch (e) {
      debugPrint("Error loading units: $e");
      emit(UnitError(e.toString()));
    }
  }

  Future<void> _onLoadUnitsWithPagination(
      LoadUnitsWithPagination event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      // Repository'de pagination için metod eklenmesi gerekir
      final loadedUnits = await repository.getUnits();
      units = loadedUnits;
      emit(UnitsLoaded(units));
    } catch (e) {
      emit(UnitError(e.toString()));
    }
  }

  Future<void> _onSearchUnits(
      SearchUnits event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      // Repository'de arama için metod eklenmesi gerekir
      final filteredUnits = units.where((unit) => 
        unit.unitName.toLowerCase().contains(event.query.toLowerCase())).toList();
      emit(UnitsLoaded(filteredUnits));
    } catch (e) {
      emit(UnitError(e.toString()));
    }
  }

  Future<void> _onSelectUnit(
      SelectUnit event, Emitter<UnitState> emit) async {
    if (event.unit == null) {
      selectedUnit = null;
      emit(UnitsLoaded(units));
      return;
    }

    emit(UnitLoading());
    try {
      final unit = await repository.getUnitById(event.unit!.id!);
      selectedUnit = unit;
      emit(UnitSelected(unit, units: units));
    } catch (e) {
      emit(UnitError(e.toString()));
    }
  }

  Future<void> _onAddUnit(
      AddUnit event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      final newUnit = await repository.addUnit(event.unit);
      units.add(newUnit);
      emit(UnitOperationSuccess('Ünite başarıyla eklendi.', units: units));
      emit(UnitsLoaded(units));
    } catch (e) {
      debugPrint("Ünite ekleme hatası: ${e.toString()}");
      emit(UnitError("Ünite eklenemedi: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateUnit(
      UpdateUnit event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      final updatedUnit = await repository.updateUnit(event.unit);
      final index = units.indexWhere((u) => u.id == updatedUnit.id);
      if (index != -1) {
        units[index] = updatedUnit;
      }
      
      if (selectedUnit?.id == updatedUnit.id) {
        selectedUnit = updatedUnit;
      }
      
      emit(UnitOperationSuccess('Ünite başarıyla güncellendi.', 
        units: units,
        selectedUnit: selectedUnit
      ));
      emit(UnitsLoaded(units, selectedUnit: selectedUnit));
    } catch (e) {
      debugPrint("Ünite güncelleme hatası: ${e.toString()}");
      emit(UnitError("Ünite güncellenemedi: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteUnit(
      DeleteUnit event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      final success = await repository.deleteUnit(event.unitId);
      if (success) {
        units.removeWhere((unit) => unit.id == event.unitId);
        
        if (selectedUnit?.id == event.unitId) {
          selectedUnit = null;
        }
        
        emit(UnitOperationSuccess('Ünite başarıyla silindi.'));
        emit(UnitsLoaded(units));
      } else {
        emit(UnitError('Ünite silinemedi.'));
      }
    } catch (e) {
      emit(UnitError(e.toString()));
    }
  }

  Future<void> _onUploadUnitExcel(
      UploadUnitExcel event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      final success = await repository.importUnitsFromExcel(event.file);
      if (success) {
        // Excel import sonrası ünite listesini yenile
        final loadedUnits = await repository.getUnits();
        units = loadedUnits;
        
        emit(UnitOperationSuccess('Üniteler Excel\'den başarıyla içe aktarıldı.'));
        emit(UnitsLoaded(units));
      } else {
        emit(UnitError('Üniteler Excel\'den içe aktarılamadı.'));
      }
    } catch (e) {
      debugPrint("Excel'den ünite içe aktarma hatası: ${e.toString()}");
      emit(UnitError("Excel'den ünite içe aktarılamadı: ${e.toString()}"));
    }
  }

  void _onUnitLoading(UnitLoadingEvent event, Emitter<UnitState> emit) {
    emit(UnitLoading());
  }
} 