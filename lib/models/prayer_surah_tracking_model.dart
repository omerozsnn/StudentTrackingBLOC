class PrayerSurahTracking {
  final int? id;
  final int duaSureOgrenciId;
  final String durum;
  final String? degerlendirme;
  final String? ekgorus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? prayerSurahStudent;

  PrayerSurahTracking({
    this.id,
    required this.duaSureOgrenciId,
    required this.durum,
    this.degerlendirme,
    this.ekgorus,
    this.createdAt,
    this.updatedAt,
    this.prayerSurahStudent,
  });

  factory PrayerSurahTracking.fromJson(Map<String, dynamic> json) {
    return PrayerSurahTracking(
      id: json['id'],
      duaSureOgrenciId: json['dua_sure_ogrenci_id'],
      durum: json['durum'] ?? 'Okumadı',
      degerlendirme: json['degerlendirme'],
      ekgorus: json['ekgorus'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      prayerSurahStudent: json['prayer_surah_student'] != null
          ? Map<String, dynamic>.from(json['prayer_surah_student'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dua_sure_ogrenci_id': duaSureOgrenciId,
      'durum': durum,
      'degerlendirme': degerlendirme,
      'ekgorus': ekgorus,
    };
  }

  PrayerSurahTracking copyWith({
    int? id,
    int? duaSureOgrenciId,
    String? durum,
    String? degerlendirme,
    String? ekgorus,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? prayerSurahStudent,
  }) {
    return PrayerSurahTracking(
      id: id ?? this.id,
      duaSureOgrenciId: duaSureOgrenciId ?? this.duaSureOgrenciId,
      durum: durum ?? this.durum,
      degerlendirme: degerlendirme ?? this.degerlendirme,
      ekgorus: ekgorus ?? this.ekgorus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      prayerSurahStudent: prayerSurahStudent ?? this.prayerSurahStudent,
    );
  }
}
