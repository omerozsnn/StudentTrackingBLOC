import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/kds_model.dart';

abstract class KDSState extends Equatable {
  final List<KDS> kdsList;
  final KDS? selectedKDS;
  final List<KDSImage> kdsImages;

  const KDSState({
    this.kdsList = const <KDS>[],
    this.selectedKDS,
    this.kdsImages = const <KDSImage>[],
  });

  @override
  List<Object?> get props => [kdsList, selectedKDS, kdsImages];
}

// Başlangıç durumu
class KDSInitial extends KDSState {
  const KDSInitial() : super();
}

// Yükleme durumu
class KDSLoading extends KDSState {
  const KDSLoading({
    List<KDS> kdsList = const <KDS>[],
    KDS? selectedKDS,
    List<KDSImage> kdsImages = const <KDSImage>[],
  }) : super(
          kdsList: kdsList,
          selectedKDS: selectedKDS,
          kdsImages: kdsImages,
        );
}

// KDS listesi yüklendi durumu
class KDSListLoaded extends KDSState {
  const KDSListLoaded(
    List<KDS> kdsList, {
    KDS? selectedKDS,
    List<KDSImage> kdsImages = const <KDSImage>[],
  }) : super(
          kdsList: kdsList,
          selectedKDS: selectedKDS,
          kdsImages: kdsImages,
        );
}

// KDS seçildi durumu
class KDSSelected extends KDSState {
  const KDSSelected(
    KDS kds, {
    List<KDS> kdsList = const <KDS>[],
    List<KDSImage> kdsImages = const <KDSImage>[],
  }) : super(
          kdsList: kdsList,
          selectedKDS: kds,
          kdsImages: kdsImages,
        );
}

// KDS resim yükleme durumu
class KDSImagesLoaded extends KDSState {
  const KDSImagesLoaded(
    List<KDSImage> kdsImages, {
    List<KDS> kdsList = const <KDS>[],
    KDS? selectedKDS,
  }) : super(
          kdsList: kdsList,
          selectedKDS: selectedKDS,
          kdsImages: kdsImages,
        );
}

// İşlem başarılı durumu
class KDSOperationSuccess extends KDSState {
  final String message;

  const KDSOperationSuccess(
    this.message, {
    List<KDS> kdsList = const <KDS>[],
    KDS? selectedKDS,
    List<KDSImage> kdsImages = const <KDSImage>[],
  }) : super(
          kdsList: kdsList,
          selectedKDS: selectedKDS,
          kdsImages: kdsImages,
        );

  @override
  List<Object?> get props => [message, kdsList, selectedKDS, kdsImages];
}

// Hata durumu
class KDSError extends KDSState {
  final String message;

  const KDSError(
    this.message, {
    List<KDS> kdsList = const <KDS>[],
    KDS? selectedKDS,
    List<KDSImage> kdsImages = const <KDSImage>[],
  }) : super(
          kdsList: kdsList,
          selectedKDS: selectedKDS,
          kdsImages: kdsImages,
        );

  @override
  List<Object?> get props => [message, kdsList, selectedKDS, kdsImages];
}
