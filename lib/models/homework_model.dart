class Homework {
  final int? id;
  final String odevAdi;
  final DateTime teslimTarihi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Homework({
    this.id,
    required this.odevAdi,
    required this.teslimTarihi,
    this.createdAt,
    this.updatedAt,
  });

  // Create from JSON
  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['id'],
      odevAdi: json['odev_adi'],
      teslimTarihi: DateTime.parse(json['teslim_tarihi']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'odev_adi': odevAdi,
      'teslim_tarihi': teslimTarihi.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  Homework copyWith({
    int? id,
    String? odevAdi,
    DateTime? teslimTarihi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Homework(
      id: id ?? this.id,
      odevAdi: odevAdi ?? this.odevAdi,
      teslimTarihi: teslimTarihi ?? this.teslimTarihi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
