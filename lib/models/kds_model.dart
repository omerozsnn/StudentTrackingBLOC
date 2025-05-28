class KDS {
  final int? id;
  final String kdsName;
  final int questionCount;
  final int? unitId;
  final Map<String, dynamic>? answersheet;
  final List<KDSImage>? images;

  KDS({
    this.id,
    required this.kdsName,
    required this.questionCount,
    required this.unitId,
    this.answersheet,
    this.images,
  });

  factory KDS.fromJson(Map<String, dynamic> json) {
    List<KDSImage>? imagesList;

    if (json['images'] != null) {
      imagesList = List<KDSImage>.from(
          json['images'].map((image) => KDSImage.fromJson(image)));
    }

    return KDS(
      id: json['id'],
      kdsName: json['kds_adi'] ?? '',
      questionCount: json['calisma_soru_sayisi'] ?? 0,
      unitId: json['unite_id'],
      answersheet: json['answersheet'],
      images: imagesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kds_adi': kdsName,
      'calisma_soru_sayisi': questionCount,
      'unite_id': unitId,
      if (answersheet != null) 'answersheet': answersheet,
    };
  }
}

class KDSImage {
  final int? id;
  final int? kdsId;
  final String? imagePath;

  KDSImage({
    this.id,
    this.kdsId,
    this.imagePath,
  });

  factory KDSImage.fromJson(Map<String, dynamic> json) {
    return KDSImage(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      kdsId: json['kds_id'] is String
          ? int.tryParse(json['kds_id'])
          : json['kds_id'],
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (kdsId != null) 'kds_id': kdsId,
      if (imagePath != null) 'image_path': imagePath,
    };
  }
}
