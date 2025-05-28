import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/kds_class_model.dart';

abstract class KdsClassState extends Equatable {
  final List<KdsClass> assignedKdsList;

  const KdsClassState({
    this.assignedKdsList = const <KdsClass>[],
  });

  @override
  List<Object?> get props => [assignedKdsList];
}

// Başlangıç durumu
class KdsClassInitial extends KdsClassState {
  const KdsClassInitial() : super();
}

// Yükleniyor durumu
class KdsClassLoading extends KdsClassState {
  const KdsClassLoading({
    List<KdsClass> assignedKdsList = const <KdsClass>[],
  }) : super(
          assignedKdsList: assignedKdsList,
        );
}

// KDS listesi yüklendi durumu
class KdsAssignedListLoaded extends KdsClassState {
  const KdsAssignedListLoaded(
    List<KdsClass> assignedKdsList,
  ) : super(
          assignedKdsList: assignedKdsList,
        );
}

// İşlem başarılı durumu
class KdsClassOperationSuccess extends KdsClassState {
  final String message;

  const KdsClassOperationSuccess(
    this.message, {
    List<KdsClass> assignedKdsList = const <KdsClass>[],
  }) : super(
          assignedKdsList: assignedKdsList,
        );

  @override
  List<Object?> get props => [message, assignedKdsList];
}

// Hata durumu
class KdsClassError extends KdsClassState {
  final String message;

  const KdsClassError(
    this.message, {
    List<KdsClass> assignedKdsList = const <KdsClass>[],
  }) : super(
          assignedKdsList: assignedKdsList,
        );

  @override
  List<Object?> get props => [message, assignedKdsList];
}
