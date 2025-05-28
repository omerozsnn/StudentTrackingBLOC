class OkulDenemesi {
  final int? id;
  final String sinavAdi;
  final int yanlisGoturmeOrani;
  final DateTime sinavTarihi;

  OkulDenemesi({
    this.id,
    required this.sinavAdi,
    required this.yanlisGoturmeOrani,
    required this.sinavTarihi,
  });

  factory OkulDenemesi.fromJson(Map<String, dynamic> json) {
    return OkulDenemesi(
      id: json['id'],
      sinavAdi: json['sinav_adi'],
      yanlisGoturmeOrani: json['yanlis_goturme_orani'],
      sinavTarihi: DateTime.parse(json['sinav_tarihi']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sinav_adi': sinavAdi,
      'yanlis_goturme_orani': yanlisGoturmeOrani,
      'sinav_tarihi': sinavTarihi.toIso8601String(),
    };
  }

  OkulDenemesi copyWith({
    int? id,
    String? sinavAdi,
    int? yanlisGoturmeOrani,
    DateTime? sinavTarihi,
  }) {
    return OkulDenemesi(
      id: id ?? this.id,
      sinavAdi: sinavAdi ?? this.sinavAdi,
      yanlisGoturmeOrani: yanlisGoturmeOrani ?? this.yanlisGoturmeOrani,
      sinavTarihi: sinavTarihi ?? this.sinavTarihi,
    );
  }
}
