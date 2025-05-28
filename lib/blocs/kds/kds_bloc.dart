import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_repository.dart';
import 'package:ogrenci_takip_sistemi/models/kds_model.dart';

class KDSBloc extends Bloc<KDSEvent, KDSState> {
  final KDSRepository repository;
  List<KDS> kdsList = [];
  KDS? selectedKDS;
  List<KDSImage> kdsImages = [];

  KDSBloc({required this.repository}) : super(const KDSInitial()) {
    on<LoadKDSList>(_onLoadKDSList);
    on<SelectKDS>(_onSelectKDS);
    on<AddKDS>(_onAddKDS);
    on<UpdateKDS>(_onUpdateKDS);
    on<DeleteKDS>(_onDeleteKDS);
    on<SearchKDS>(_onSearchKDS);
    on<LoadKDSByUnit>(_onLoadKDSByUnit);
    on<LoadKDSImages>(_onLoadKDSImages);
    on<AddKDSImages>(_onAddKDSImages);
    on<DeleteKDSImage>(_onDeleteKDSImage);
    on<KDSLoadingEvent>(_onKDSLoading);
  }

  Future<void> _onLoadKDSList(LoadKDSList event, Emitter<KDSState> emit) async {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      debugPrint("Loading KDS list...");
      final loadedKdsList = await repository.getAllKDS();
      debugPrint("KDS list loaded: ${loadedKdsList.length}");
      kdsList = loadedKdsList;
      emit(KDSListLoaded(kdsList,
          selectedKDS: selectedKDS, kdsImages: kdsImages));
    } catch (e) {
      debugPrint("Error loading KDS list: $e");
      emit(KDSError(e.toString(),
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  Future<void> _onSelectKDS(SelectKDS event, Emitter<KDSState> emit) async {
    if (event.kds == null) {
      selectedKDS = null;
      kdsImages = [];
      emit(KDSListLoaded(kdsList));
      return;
    }

    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      final kds = await repository.getKDSById(event.kds!.id!);
      selectedKDS = kds;

      // Load KDS images
      final images = await repository.getKDSImages(kds.id!);
      kdsImages = images;

      emit(KDSSelected(kds, kdsList: kdsList, kdsImages: kdsImages));
    } catch (e) {
      emit(KDSError(e.toString(),
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  Future<void> _onAddKDS(AddKDS event, Emitter<KDSState> emit) async {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      final newKDS = await repository.addKDS(event.kds);
      kdsList = [...kdsList, newKDS];

      // Upload images if provided
      if (event.images != null && event.images!.isNotEmpty) {
        try {
          final uploadedImages =
              await repository.addKDSImages(newKDS.id!, event.images!);
          kdsImages = uploadedImages;
        } catch (imageError) {
          debugPrint("KDS resimleri yüklenemedi: $imageError");
          // Resimlerde hata olsa bile işleme devam et
        }
      }

      emit(KDSOperationSuccess(
        'KDS başarıyla eklendi.',
        kdsList: kdsList,
        selectedKDS: newKDS,
        kdsImages: kdsImages,
      ));
      emit(KDSListLoaded(kdsList, selectedKDS: newKDS, kdsImages: kdsImages));
    } catch (e) {
      debugPrint("KDS ekleme hatası: ${e.toString()}");
      emit(KDSError("KDS eklenemedi: ${e.toString()}",
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  Future<void> _onUpdateKDS(UpdateKDS event, Emitter<KDSState> emit) async {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      final updatedKDS = await repository.updateKDS(event.kds.id!, event.kds);
      final index = kdsList.indexWhere((kds) => kds.id == updatedKDS.id);
      if (index != -1) {
        kdsList[index] = updatedKDS;
      }

      selectedKDS = updatedKDS;

      // Upload images if provided
      if (event.images != null && event.images!.isNotEmpty) {
        try {
          final uploadedImages =
              await repository.addKDSImages(updatedKDS.id!, event.images!);
          kdsImages = [...kdsImages, ...uploadedImages];
        } catch (imageError) {
          debugPrint("KDS resimleri yüklenemedi: $imageError");
          // Resimlerde hata olsa bile işleme devam et
        }
      }

      emit(KDSOperationSuccess(
        'KDS başarıyla güncellendi.',
        kdsList: kdsList,
        selectedKDS: selectedKDS,
        kdsImages: kdsImages,
      ));
      emit(KDSListLoaded(kdsList,
          selectedKDS: selectedKDS, kdsImages: kdsImages));
    } catch (e) {
      debugPrint("KDS güncelleme hatası: ${e.toString()}");
      emit(KDSError("KDS güncellenemedi: ${e.toString()}",
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  Future<void> _onDeleteKDS(DeleteKDS event, Emitter<KDSState> emit) async {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      final success = await repository.deleteKDS(event.kdsId);
      if (success) {
        kdsList.removeWhere((kds) => kds.id == event.kdsId);

        if (selectedKDS?.id == event.kdsId) {
          selectedKDS = null;
          kdsImages = [];
        }

        emit(KDSOperationSuccess('KDS başarıyla silindi.', kdsList: kdsList));
        emit(KDSListLoaded(kdsList));
      } else {
        emit(KDSError('KDS silinemedi.',
            kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
      }
    } catch (e) {
      emit(KDSError(e.toString(),
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  Future<void> _onSearchKDS(SearchKDS event, Emitter<KDSState> emit) async {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      final filteredKDSList = kdsList
          .where((kds) =>
              kds.kdsName.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(KDSListLoaded(filteredKDSList,
          selectedKDS: selectedKDS, kdsImages: kdsImages));
    } catch (e) {
      emit(KDSError(e.toString(),
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  Future<void> _onLoadKDSByUnit(
      LoadKDSByUnit event, Emitter<KDSState> emit) async {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      final unitKDSList = await repository.getKDSByUnit(event.unitId);
      kdsList = unitKDSList;
      emit(KDSListLoaded(kdsList,
          selectedKDS: selectedKDS, kdsImages: kdsImages));
    } catch (e) {
      emit(KDSError(e.toString(),
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  Future<void> _onLoadKDSImages(
      LoadKDSImages event, Emitter<KDSState> emit) async {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      final images = await repository.getKDSImages(event.kdsId);
      kdsImages = images;
      emit(KDSImagesLoaded(kdsImages,
          kdsList: kdsList, selectedKDS: selectedKDS));
    } catch (e) {
      emit(KDSError(e.toString(),
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  Future<void> _onAddKDSImages(
      AddKDSImages event, Emitter<KDSState> emit) async {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      final uploadedImages =
          await repository.addKDSImages(event.kdsId, event.images);
      if (uploadedImages != null) {
        kdsImages = [...kdsImages, ...uploadedImages];
      }
      emit(KDSOperationSuccess(
        'KDS resimleri başarıyla eklendi.',
        kdsList: kdsList,
        selectedKDS: selectedKDS,
        kdsImages: kdsImages,
      ));
      emit(KDSImagesLoaded(kdsImages,
          kdsList: kdsList, selectedKDS: selectedKDS));
    } catch (e) {
      debugPrint("KDS resimleri ekleme hatası: ${e.toString()}");
      emit(KDSError("KDS resimleri eklenemedi: ${e.toString()}",
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  Future<void> _onDeleteKDSImage(
      DeleteKDSImage event, Emitter<KDSState> emit) async {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
    try {
      final success = await repository.deleteKDSImage(event.imageId);
      if (success) {
        kdsImages.removeWhere((image) => image.id == event.imageId);
        emit(KDSOperationSuccess(
          'KDS resmi başarıyla silindi.',
          kdsList: kdsList,
          selectedKDS: selectedKDS,
          kdsImages: kdsImages,
        ));
        emit(KDSImagesLoaded(kdsImages,
            kdsList: kdsList, selectedKDS: selectedKDS));
      } else {
        emit(KDSError('KDS resmi silinemedi.',
            kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
      }
    } catch (e) {
      emit(KDSError(e.toString(),
          kdsList: kdsList, selectedKDS: selectedKDS, kdsImages: kdsImages));
    }
  }

  void _onKDSLoading(KDSLoadingEvent event, Emitter<KDSState> emit) {
    emit(KDSLoading(
      kdsList: kdsList,
      selectedKDS: selectedKDS,
      kdsImages: kdsImages,
    ));
  }
}
