class KdsClass {
  final int? id;
  final int? kdsId;
  final int? classId;
  final String? createdAt;
  final String? updatedAt;

  // KDS ve sınıf adlarını içeren ek bilgiler (isteğe bağlı)
  final String? kdsName;
  final String? className;
  final int? questionCount;

  KdsClass({
    this.id,
    this.kdsId,
    this.classId,
    this.createdAt,
    this.updatedAt,
    this.kdsName,
    this.className,
    this.questionCount,
  });

  factory KdsClass.fromJson(Map<String, dynamic> json) {
    // API yanıtına göre adaptasyon yap
    // Eğer API içiçe nesneler dönüyorsa (örn: { kds: {...}, class: {...} }) onları da destekle

    Map<String, dynamic>? kdsData;
    Map<String, dynamic>? classData;

    if (json.containsKey('kds') && json['kds'] != null) {
      kdsData =
          json['kds'] is Map ? Map<String, dynamic>.from(json['kds']) : null;
    }

    if (json.containsKey('class') && json['class'] != null) {
      classData = json['class'] is Map
          ? Map<String, dynamic>.from(json['class'])
          : null;
    }

    // Helper function to safely convert to int
    int? safeIntParse(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return KdsClass(
      id: safeIntParse(json['id']),
      kdsId: kdsData != null
          ? safeIntParse(kdsData['id'])
          : safeIntParse(json['kds_id']),
      classId: classData != null
          ? safeIntParse(classData['id'])
          : safeIntParse(json['class_id'] ?? json['sinif_id']), // Try both keys
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      kdsName: kdsData != null ? kdsData['kds_adi'] : null,
      className: classData != null ? classData['sinif_adi'] : null,
      questionCount: kdsData != null ? kdsData['calisma_soru_sayisi'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (kdsId != null) 'kds_id': kdsId,
      if (classId != null) 'class_id': classId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}
