class StudentHomework {
  final int? id;
  final int ogrenciId;
  final int odevId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // İlişkili veriler için opsiyonel alanlar
  final dynamic ogrenci; // Öğrenci bilgileri
  final dynamic odev; // Ödev bilgileri
  final bool? tamamlandi;
  final String? notlar;

  StudentHomework({
    this.id,
    required this.ogrenciId,
    required this.odevId,
    this.createdAt,
    this.updatedAt,
    this.ogrenci,
    this.odev,
    this.tamamlandi,
    this.notlar,
  });

  factory StudentHomework.fromJson(Map<String, dynamic> json) {
    return StudentHomework(
      id: json['id'],
      ogrenciId: json['ogrenci_id'],
      odevId: json['odev_id'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      ogrenci: json['ogrenci'],
      odev: json['odev'],
      tamamlandi: json['tamamlandi'],
      notlar: json['notlar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ogrenci_id': ogrenciId,
      'odev_id': odevId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'tamamlandi': tamamlandi,
      'notlar': notlar,
    };
  }

  // Create a copy with updated fields
  StudentHomework copyWith({
    int? id,
    int? ogrenciId,
    int? odevId,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic ogrenci,
    dynamic odev,
    bool? tamamlandi,
    String? notlar,
  }) {
    return StudentHomework(
      id: id ?? this.id,
      ogrenciId: ogrenciId ?? this.ogrenciId,
      odevId: odevId ?? this.odevId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ogrenci: ogrenci ?? this.ogrenci,
      odev: odev ?? this.odev,
      tamamlandi: tamamlandi ?? this.tamamlandi,
      notlar: notlar ?? this.notlar,
    );
  }
}
