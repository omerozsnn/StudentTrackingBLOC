class Course {
  final int id;
  final String dersAdi;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? egitimOgretimYiliId;

  Course({
    required this.id,
    required this.dersAdi,
    this.createdAt,
    this.updatedAt,
    this.egitimOgretimYiliId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? json['ders_id'],
      dersAdi: json['ders_adi'] ?? 'Unknown',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      egitimOgretimYiliId: json['egitimOgretimYiliId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ders_adi': dersAdi,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'egitimOgretimYiliId': egitimOgretimYiliId,
    };
  }
}
