import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';
import 'dart:io';

@immutable
abstract class OgrenciDenemeEvent extends Equatable {
  const OgrenciDenemeEvent();

  @override
  List<Object?> get props => [];
}

// Tüm öğrenci deneme sınavı sonuçlarını yükleme
class LoadAllOgrenciDenemeResults extends OgrenciDenemeEvent {}

// Belirli bir öğrencinin deneme sınavı sonuçlarını yükleme
class LoadOgrenciDenemeResultsByStudent extends OgrenciDenemeEvent {
  final int ogrenciId;

  const LoadOgrenciDenemeResultsByStudent(this.ogrenciId);

  @override
  List<Object?> get props => [ogrenciId];
}

// Belirli bir deneme sınavına ait tüm öğrenci sonuçlarını yükleme
class LoadOgrenciDenemeResultsByExam extends OgrenciDenemeEvent {
  final int denemeSinaviId;

  const LoadOgrenciDenemeResultsByExam(this.denemeSinaviId);

  @override
  List<Object?> get props => [denemeSinaviId];
}

// Öğrenci deneme sınavı sonucu ekleme
class AddOgrenciDenemeResult extends OgrenciDenemeEvent {
  final StudentExamResult result;

  const AddOgrenciDenemeResult(this.result);

  @override
  List<Object?> get props => [result];
}

// Öğrenci deneme sınavı sonucu güncelleme
class UpdateOgrenciDenemeResult extends OgrenciDenemeEvent {
  final int ogrenciId;
  final int denemeSinaviId;
  final Map<String, dynamic> data;

  const UpdateOgrenciDenemeResult({
    required this.ogrenciId,
    required this.denemeSinaviId, 
    required this.data,
  });

  @override
  List<Object?> get props => [ogrenciId, denemeSinaviId, data];
}

// Öğrenci deneme sınavı sonucu silme
class DeleteOgrenciDenemeResult extends OgrenciDenemeEvent {
  final int id;

  const DeleteOgrenciDenemeResult(this.id);

  @override
  List<Object?> get props => [id];
}

// Excel'den öğrenci deneme sonuçlarını yükleme
class UploadOgrenciDenemeExcel extends OgrenciDenemeEvent {
  final File file;

  const UploadOgrenciDenemeExcel(this.file);

  @override
  List<Object?> get props => [file];
}

// Öğrenci deneme sınavı katılım bilgilerini getirme
class LoadOgrenciDenemeParticipation extends OgrenciDenemeEvent {
  final int ogrenciId;

  const LoadOgrenciDenemeParticipation(this.ogrenciId);

  @override
  List<Object?> get props => [ogrenciId];
}

// Sınıf deneme sınavı ortalamalarını getirme
class LoadClassDenemeAverages extends OgrenciDenemeEvent {
  final int sinifId;
  final int ogrenciId;

  const LoadClassDenemeAverages(this.sinifId, this.ogrenciId);

  @override
  List<Object?> get props => [sinifId, ogrenciId];
}

// Yükleme durumu olayı
class OgrenciDenemeLoadingEvent extends OgrenciDenemeEvent {} 