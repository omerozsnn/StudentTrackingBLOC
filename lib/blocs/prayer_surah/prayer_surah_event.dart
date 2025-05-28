import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';

abstract class PrayerSurahEvent extends Equatable {
  const PrayerSurahEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrayerSurahs extends PrayerSurahEvent {}

class AddPrayerSurah extends PrayerSurahEvent {
  final PrayerSurah prayerSurah;

  const AddPrayerSurah(this.prayerSurah);

  @override
  List<Object?> get props => [prayerSurah];
}

class UpdatePrayerSurah extends PrayerSurahEvent {
  final PrayerSurah prayerSurah;

  const UpdatePrayerSurah(this.prayerSurah);

  @override
  List<Object?> get props => [prayerSurah];
}

class DeletePrayerSurah extends PrayerSurahEvent {
  final int id;

  const DeletePrayerSurah(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectPrayerSurah extends PrayerSurahEvent {
  final PrayerSurah? prayerSurah;

  const SelectPrayerSurah(this.prayerSurah);

  @override
  List<Object?> get props => [prayerSurah];
}
