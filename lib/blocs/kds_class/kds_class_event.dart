import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/kds_class_model.dart';

@immutable
abstract class KdsClassEvent extends Equatable {
  const KdsClassEvent();

  @override
  List<Object?> get props => [];
}

// Bir sınıfa atanmış KDS'leri yükleme eventi
class LoadKdsByClass extends KdsClassEvent {
  final int classId;

  const LoadKdsByClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

// Bir KDS'yi bir sınıfa atama eventi
class AssignKdsToClass extends KdsClassEvent {
  final int kdsId;
  final int classId;

  const AssignKdsToClass(this.kdsId, this.classId);

  @override
  List<Object?> get props => [kdsId, classId];
}

// Bir KDS'yi 6. sınıf seviyesine atama eventi
class AssignKdsToSixthGrade extends KdsClassEvent {
  final int kdsId;

  const AssignKdsToSixthGrade(this.kdsId);

  @override
  List<Object?> get props => [kdsId];
}

// Bir KDS'yi 7. sınıf seviyesine atama eventi
class AssignKdsToSeventhGrade extends KdsClassEvent {
  final int kdsId;

  const AssignKdsToSeventhGrade(this.kdsId);

  @override
  List<Object?> get props => [kdsId];
}

// Bir KDS'yi 8. sınıf seviyesine atama eventi
class AssignKdsToEighthGrade extends KdsClassEvent {
  final int kdsId;

  const AssignKdsToEighthGrade(this.kdsId);

  @override
  List<Object?> get props => [kdsId];
}

// Çoklu KDS'leri atama eventi
class AssignMultipleKdsToClasses extends KdsClassEvent {
  final List<int> kdsIds;
  final int? classId;
  final String? classLevel;
  final bool isClassLevelSelected;

  const AssignMultipleKdsToClasses({
    required this.kdsIds,
    this.classId,
    this.classLevel,
    required this.isClassLevelSelected,
  });

  @override
  List<Object?> get props =>
      [kdsIds, classId, classLevel, isClassLevelSelected];
}

// Bir KDS'yi bir sınıftan kaldırma eventi
class DeleteKdsFromClass extends KdsClassEvent {
  final int kdsId;
  final int classId;

  const DeleteKdsFromClass(this.kdsId, this.classId);

  @override
  List<Object?> get props => [kdsId, classId];
}

// KDS sınıf operasyonu yükleniyor eventi
class KdsClassLoadingEvent extends KdsClassEvent {}
