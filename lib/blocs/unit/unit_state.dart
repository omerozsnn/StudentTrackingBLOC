import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/units_model.dart';

abstract class UnitState extends Equatable {
  final List<Unit> units;
  final Unit? selectedUnit;

  const UnitState({
    this.units = const <Unit>[],
    this.selectedUnit,
  });

  @override
  List<Object?> get props => [units, selectedUnit];
}

// Başlangıç durumu
class UnitInitial extends UnitState {
  const UnitInitial() : super();
}

// Yükleme durumu
class UnitLoading extends UnitState {
  const UnitLoading({
    List<Unit> units = const <Unit>[],
    Unit? selectedUnit,
  }) : super(
          units: units,
          selectedUnit: selectedUnit,
        );
}

// Üniteler yüklendi durumu
class UnitsLoaded extends UnitState {
  const UnitsLoaded(
    List<Unit> units, {
    Unit? selectedUnit,
  }) : super(
          units: units,
          selectedUnit: selectedUnit,
        );
}

// Ünite seçildi durumu
class UnitSelected extends UnitState {
  const UnitSelected(
    Unit unit, {
    List<Unit> units = const <Unit>[],
  }) : super(
          units: units,
          selectedUnit: unit,
        );
}

// Hata durumu
class UnitError extends UnitState {
  final String message;

  const UnitError(
    this.message, {
    List<Unit> units = const <Unit>[],
    Unit? selectedUnit,
  }) : super(
          units: units,
          selectedUnit: selectedUnit,
        );

  @override
  List<Object?> get props => [message, units, selectedUnit];
}

// İşlem başarılı durumu
class UnitOperationSuccess extends UnitState {
  final String message;

  const UnitOperationSuccess(
    this.message, {
    List<Unit> units = const <Unit>[],
    Unit? selectedUnit,
  }) : super(
          units: units,
          selectedUnit: selectedUnit,
        );

  @override
  List<Object?> get props => [message, units, selectedUnit];
} 