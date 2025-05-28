import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/deneme_sinavi_model.dart';
import 'dart:io';

@immutable
abstract class DenemeSinaviEvent extends Equatable {
  const DenemeSinaviEvent();

  @override
  List<Object?> get props => [];
}

// Tüm deneme sınavlarını yükleme olayı
class LoadDenemeSinavlari extends DenemeSinaviEvent {}

// Sayfalama ile deneme sınavlarını yükleme olayı
class LoadDenemeSinavlariWithPagination extends DenemeSinaviEvent {
  final int page;
  final int limit;

  const LoadDenemeSinavlariWithPagination({
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [page, limit];
}

// Belirli bir üniteye ait deneme sınavlarını yükleme olayı
class LoadDenemeSinavlariByUnit extends DenemeSinaviEvent {
  final int uniteId;

  const LoadDenemeSinavlariByUnit(this.uniteId);

  @override
  List<Object?> get props => [uniteId];
}

// Deneme sınavı arama olayı
class SearchDenemeSinavlari extends DenemeSinaviEvent {
  final String query;

  const SearchDenemeSinavlari(this.query);

  @override
  List<Object?> get props => [query];
}

// Deneme sınavı seçme olayı
class SelectDenemeSinavi extends DenemeSinaviEvent {
  final DenemeSinavi? denemeSinavi;

  const SelectDenemeSinavi(this.denemeSinavi);

  @override
  List<Object?> get props => [denemeSinavi];
}

// Deneme sınavı ekleme olayı
class AddDenemeSinavi extends DenemeSinaviEvent {
  final DenemeSinavi denemeSinavi;

  const AddDenemeSinavi(this.denemeSinavi);

  @override
  List<Object?> get props => [denemeSinavi];
}

// Deneme sınavı güncelleme olayı
class UpdateDenemeSinavi extends DenemeSinaviEvent {
  final DenemeSinavi denemeSinavi;

  const UpdateDenemeSinavi(this.denemeSinavi);

  @override
  List<Object?> get props => [denemeSinavi];
}

// Deneme sınavı silme olayı
class DeleteDenemeSinavi extends DenemeSinaviEvent {
  final int denemeSinaviId;

  const DeleteDenemeSinavi(this.denemeSinaviId);

  @override
  List<Object?> get props => [denemeSinaviId];
}

// Excel'den deneme sınavı yükleme olayı
class UploadDenemeSinaviExcel extends DenemeSinaviEvent {
  final File file;

  const UploadDenemeSinaviExcel(this.file);

  @override
  List<Object?> get props => [file];
}

// Yükleme durumu olayı
class DenemeSinaviLoadingEvent extends DenemeSinaviEvent {} 