class DefterKitap {
  final int id;
  final String tarih;
  final String defterDurum;
  final String kitapDurum;
  final int egitimOgretimYiliId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Map<String, dynamic>>? students;
  final List<Map<String, dynamic>>? courseClasses;

  DefterKitap({
    required this.id,
    required this.tarih,
    required this.defterDurum,
    required this.kitapDurum,
    required this.egitimOgretimYiliId,
    this.createdAt,
    this.updatedAt,
    this.students,
    this.courseClasses,
  });

  factory DefterKitap.fromJson(Map<String, dynamic> json) {
    return DefterKitap(
      id: json['id'],
      tarih: json['tarih'],
      defterDurum: json['defter_durum'],
      kitapDurum: json['kitap_durum'],
      egitimOgretimYiliId: json['egitimOgretimYiliId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      students: json['students'] != null
          ? List<Map<String, dynamic>>.from(json['students'])
          : null,
      courseClasses: json['courseClasses'] != null
          ? List<Map<String, dynamic>>.from(json['courseClasses'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tarih': tarih,
      'defter_durum': defterDurum,
      'kitap_durum': kitapDurum,
      'egitimOgretimYiliId': egitimOgretimYiliId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'students': students,
      'courseClasses': courseClasses,
    };
  }

  // Veri oluşturma için yardımcı yöntem
  static Map<String, dynamic> createDefterKitapData({
    required String tarih,
    required String defterDurum,
    required String kitapDurum,
    required int sinifDersleriId,
    required int ogrenciId,
  }) {
    return {
      'tarih': tarih,
      'defter_durum': defterDurum,
      'kitap_durum': kitapDurum,
      'sinif_dersleri_id': sinifDersleriId,
      'ogrenci_id': ogrenciId,
    };
  }

  // Veriyi güncellemek için yeni bir kopya oluşturur
  DefterKitap copyWith({
    int? id,
    String? tarih,
    String? defterDurum,
    String? kitapDurum,
    int? egitimOgretimYiliId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? students,
    List<Map<String, dynamic>>? courseClasses,
  }) {
    return DefterKitap(
      id: id ?? this.id,
      tarih: tarih ?? this.tarih,
      defterDurum: defterDurum ?? this.defterDurum,
      kitapDurum: kitapDurum ?? this.kitapDurum,
      egitimOgretimYiliId: egitimOgretimYiliId ?? this.egitimOgretimYiliId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      students: students ?? this.students,
      courseClasses: courseClasses ?? this.courseClasses,
    );
  }
}
