import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/kds_model.dart';
import 'dart:io';

@immutable
abstract class KDSEvent extends Equatable {
  const KDSEvent();

  @override
  List<Object?> get props => [];
}

// Tüm KDS'leri yükleme olayı
class LoadKDSList extends KDSEvent {}

// KDS seçme olayı
class SelectKDS extends KDSEvent {
  final KDS? kds;

  const SelectKDS(this.kds);

  @override
  List<Object?> get props => [kds];
}

// KDS ekleme olayı
class AddKDS extends KDSEvent {
  final KDS kds;
  final List<File>? images;

  const AddKDS(this.kds, {this.images});

  @override
  List<Object?> get props => [kds, images];
}

// KDS güncelleme olayı
class UpdateKDS extends KDSEvent {
  final KDS kds;
  final List<File>? images;

  const UpdateKDS(this.kds, {this.images});

  @override
  List<Object?> get props => [kds, images];
}

// KDS silme olayı
class DeleteKDS extends KDSEvent {
  final int kdsId;

  const DeleteKDS(this.kdsId);

  @override
  List<Object?> get props => [kdsId];
}

// KDS arama olayı
class SearchKDS extends KDSEvent {
  final String query;

  const SearchKDS(this.query);

  @override
  List<Object?> get props => [query];
}

// Üniteye ait KDS'leri yükleme olayı
class LoadKDSByUnit extends KDSEvent {
  final int unitId;

  const LoadKDSByUnit(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

// KDS resimlerini yükleme olayı
class LoadKDSImages extends KDSEvent {
  final int kdsId;

  const LoadKDSImages(this.kdsId);

  @override
  List<Object?> get props => [kdsId];
}

// KDS resimlerini ekleme olayı
class AddKDSImages extends KDSEvent {
  final int kdsId;
  final List<File> images;

  const AddKDSImages(this.kdsId, this.images);

  @override
  List<Object?> get props => [kdsId, images];
}

// KDS resmini silme olayı
class DeleteKDSImage extends KDSEvent {
  final int imageId;

  const DeleteKDSImage(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

// Yükleme durumu olayı
class KDSLoadingEvent extends KDSEvent {}
