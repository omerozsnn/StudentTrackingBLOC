class HomeworkTracking {
  final int? id;
  final int ogrenciOdevleriId;
  final String durum;
  final String? aciklama;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // İlişkili veriler için opsiyonel alanlar
  final dynamic studentHomework; // Öğrenci ödev ilişkisi

  HomeworkTracking({
    this.id,
    required this.ogrenciOdevleriId,
    required this.durum,
    this.aciklama,
    this.createdAt,
    this.updatedAt,
    this.studentHomework,
  });

  factory HomeworkTracking.fromJson(Map<String, dynamic> json) {
    return HomeworkTracking(
      id: json['id'],
      ogrenciOdevleriId: json['ogrenci_odevleri_id'],
      durum: json['durum'] ?? 'yapmadi',
      aciklama: json['aciklama'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      studentHomework: json['studentHomework'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ogrenci_odevleri_id': ogrenciOdevleriId,
      'durum': durum,
      'aciklama': aciklama,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  HomeworkTracking copyWith({
    int? id,
    int? ogrenciOdevleriId,
    String? durum,
    String? aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic studentHomework,
  }) {
    return HomeworkTracking(
      id: id ?? this.id,
      ogrenciOdevleriId: ogrenciOdevleriId ?? this.ogrenciOdevleriId,
      durum: durum ?? this.durum,
      aciklama: aciklama ?? this.aciklama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentHomework: studentHomework ?? this.studentHomework,
    );
  }
}
