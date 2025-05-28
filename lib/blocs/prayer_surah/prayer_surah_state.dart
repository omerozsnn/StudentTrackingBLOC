import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';

enum PrayerSurahStatus { initial, loading, success, failure }

class PrayerSurahState extends Equatable {
  final PrayerSurahStatus status;
  final List<PrayerSurah> prayerSurahs;
  final PrayerSurah? selectedPrayerSurah;
  final String? errorMessage;

  const PrayerSurahState({
    this.status = PrayerSurahStatus.initial,
    this.prayerSurahs = const [],
    this.selectedPrayerSurah,
    this.errorMessage,
  });

  PrayerSurahState copyWith({
    PrayerSurahStatus? status,
    List<PrayerSurah>? prayerSurahs,
    PrayerSurah? selectedPrayerSurah,
    String? errorMessage,
    bool clearSelectedPrayerSurah = false,
    bool clearError = false,
  }) {
    return PrayerSurahState(
      status: status ?? this.status,
      prayerSurahs: prayerSurahs ?? this.prayerSurahs,
      selectedPrayerSurah: clearSelectedPrayerSurah
          ? null
          : selectedPrayerSurah ?? this.selectedPrayerSurah,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        prayerSurahs,
        selectedPrayerSurah,
        errorMessage,
      ];
}
