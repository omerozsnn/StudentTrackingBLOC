import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/units_model.dart';
import 'dart:io';

@immutable
abstract class UnitEvent extends Equatable {
  const UnitEvent();

  @override
  List<Object?> get props => [];
}

// Tüm üniteleri yükleme olayı
class LoadUnits extends UnitEvent {}

// Sayfalama ile üniteleri yükleme olayı
class LoadUnitsWithPagination extends UnitEvent {
  final int page;
  final int limit;

  const LoadUnitsWithPagination({
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [page, limit];
}

// Ünite arama olayı
class SearchUnits extends UnitEvent {
  final String query;

  const SearchUnits(this.query);

  @override
  List<Object?> get props => [query];
}

// Ünite seçme olayı
class SelectUnit extends UnitEvent {
  final Unit? unit;

  const SelectUnit(this.unit);

  @override
  List<Object?> get props => [unit];
}

// Ünite ekleme olayı
class AddUnit extends UnitEvent {
  final Unit unit;

  const AddUnit(this.unit);

  @override
  List<Object?> get props => [unit];
}

// Ünite güncelleme olayı
class UpdateUnit extends UnitEvent {
  final Unit unit;

  const UpdateUnit(this.unit);

  @override
  List<Object?> get props => [unit];
}

// Ünite silme olayı
class DeleteUnit extends UnitEvent {
  final int unitId;

  const DeleteUnit(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

// Excel'den ünite yükleme olayı (gerekirse kullanılabilir)
class UploadUnitExcel extends UnitEvent {
  final File file;

  const UploadUnitExcel(this.file);

  @override
  List<Object?> get props => [file];
}

// Yükleme durumu olayı
class UnitLoadingEvent extends UnitEvent {} 