class PrayerSurah {
  final int? id;
  final String duaSureAdi;

  PrayerSurah({
    this.id,
    required this.duaSureAdi,
  });

  factory PrayerSurah.fromJson(Map<String, dynamic> json) {
    return PrayerSurah(
      id: json['id'],
      duaSureAdi: json['dua_sure_adi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dua_sure_adi': duaSureAdi,
    };
  }

  PrayerSurah copyWith({
    int? id,
    String? duaSureAdi,
  }) {
    return PrayerSurah(
      id: id ?? this.id,
      duaSureAdi: duaSureAdi ?? this.duaSureAdi,
    );
  }
}
