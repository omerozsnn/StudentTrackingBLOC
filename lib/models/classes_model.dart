class Classes {
  final int id;
  final String sinifAdi;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? egitimOgretimYiliId;

  Classes({
    required this.id,
    required this.sinifAdi,
    this.createdAt,
    this.updatedAt,
    this.egitimOgretimYiliId,
  });

  factory Classes.fromJson(Map<String, dynamic> json) {
    print('Creating class from json: $json');
    try {
      return Classes(
        id: json['id'],
        sinifAdi: json['sinif_adi'] ?? json['sinifAdi'] ?? 'Unknown',
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        egitimOgretimYiliId: json['egitimOgretimYiliId'],
      );
    } catch (e) {
      print('Error parsing class data: $e, JSON: $json');
      // Return a placeholder class with error info to prevent app crashes
      return Classes(
        id: -1,
        sinifAdi: 'Parse Error',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sinif_adi': sinifAdi,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'egitimOgretimYiliId': egitimOgretimYiliId,
    };
  }

  Classes copyWith({
    int? id,
    String? sinifAdi,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? egitimOgretimYiliId,
  }) {
    return Classes(
      id: id ?? this.id,
      sinifAdi: sinifAdi ?? this.sinifAdi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      egitimOgretimYiliId: egitimOgretimYiliId ?? this.egitimOgretimYiliId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Classes && other.id == id && other.sinifAdi == sinifAdi;
  }

  @override
  int get hashCode => id.hashCode ^ sinifAdi.hashCode;
}
