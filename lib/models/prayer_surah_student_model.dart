class PrayerSurahStudent {
  final int? id;
  final int duaSureId;
  final int ogrenciId;
  final String? duaSureAdi;
  final String? ogrenciAdi;

  PrayerSurahStudent({
    this.id,
    required this.duaSureId,
    required this.ogrenciId,
    this.duaSureAdi,
    this.ogrenciAdi,
  });

  factory PrayerSurahStudent.fromJson(Map<String, dynamic> json) {
    return PrayerSurahStudent(
      id: json['id'],
      duaSureId: json['dua_sure_id'],
      ogrenciId: json['ogrenci_id'],
      duaSureAdi: json['dua_sure_adi'],
      ogrenciAdi: json['ogrenci_adi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dua_sure_id': duaSureId,
      'ogrenci_id': ogrenciId,
      'dua_sure_adi': duaSureAdi,
      'ogrenci_adi': ogrenciAdi,
    };
  }

  PrayerSurahStudent copyWith({
    int? id,
    int? duaSureId,
    int? ogrenciId,
    String? duaSureAdi,
    String? ogrenciAdi,
  }) {
    return PrayerSurahStudent(
      id: id ?? this.id,
      duaSureId: duaSureId ?? this.duaSureId,
      ogrenciId: ogrenciId ?? this.ogrenciId,
      duaSureAdi: duaSureAdi ?? this.duaSureAdi,
      ogrenciAdi: ogrenciAdi ?? this.ogrenciAdi,
    );
  }
}
