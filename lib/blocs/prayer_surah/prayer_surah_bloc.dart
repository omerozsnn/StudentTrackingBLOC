import 'package:bloc/bloc.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_repository.dart';

class PrayerSurahBloc extends Bloc<PrayerSurahEvent, PrayerSurahState> {
  final PrayerSurahRepository repository;

  PrayerSurahBloc({required this.repository})
      : super(const PrayerSurahState()) {
    on<LoadPrayerSurahs>(_onLoadPrayerSurahs);
    on<AddPrayerSurah>(_onAddPrayerSurah);
    on<UpdatePrayerSurah>(_onUpdatePrayerSurah);
    on<DeletePrayerSurah>(_onDeletePrayerSurah);
    on<SelectPrayerSurah>(_onSelectPrayerSurah);
  }

  Future<void> _onLoadPrayerSurahs(
      LoadPrayerSurahs event, Emitter<PrayerSurahState> emit) async {
    emit(state.copyWith(status: PrayerSurahStatus.loading));
    try {
      final prayerSurahs = await repository.getAllPrayerSurahs();
      emit(
        state.copyWith(
          status: PrayerSurahStatus.success,
          prayerSurahs: prayerSurahs,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddPrayerSurah(
      AddPrayerSurah event, Emitter<PrayerSurahState> emit) async {
    emit(state.copyWith(status: PrayerSurahStatus.loading));
    try {
      final newPrayerSurah = await repository.addPrayerSurah(event.prayerSurah);
      final updatedPrayerSurahs = List<PrayerSurah>.from(state.prayerSurahs)
        ..add(newPrayerSurah);
      emit(
        state.copyWith(
          status: PrayerSurahStatus.success,
          prayerSurahs: updatedPrayerSurahs,
          clearSelectedPrayerSurah: true,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePrayerSurah(
      UpdatePrayerSurah event, Emitter<PrayerSurahState> emit) async {
    emit(state.copyWith(status: PrayerSurahStatus.loading));
    try {
      final updatedPrayerSurah =
          await repository.updatePrayerSurah(event.prayerSurah);
      final updatedPrayerSurahs = state.prayerSurahs.map((prayerSurah) {
        if (prayerSurah.id == updatedPrayerSurah.id) {
          return updatedPrayerSurah;
        }
        return prayerSurah;
      }).toList();
      emit(
        state.copyWith(
          status: PrayerSurahStatus.success,
          prayerSurahs: updatedPrayerSurahs,
          clearSelectedPrayerSurah: true,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeletePrayerSurah(
      DeletePrayerSurah event, Emitter<PrayerSurahState> emit) async {
    emit(state.copyWith(status: PrayerSurahStatus.loading));
    try {
      final success = await repository.deletePrayerSurah(event.id);
      if (success) {
        final updatedPrayerSurahs = state.prayerSurahs
            .where((prayerSurah) => prayerSurah.id != event.id)
            .toList();
        emit(
          state.copyWith(
            status: PrayerSurahStatus.success,
            prayerSurahs: updatedPrayerSurahs,
            clearSelectedPrayerSurah: true,
            clearError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerSurahStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSelectPrayerSurah(
      SelectPrayerSurah event, Emitter<PrayerSurahState> emit) {
    emit(
      state.copyWith(
        selectedPrayerSurah: event.prayerSurah,
      ),
    );
  }
}
