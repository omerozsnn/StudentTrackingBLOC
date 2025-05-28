class OgrenciOkulDenemesi {
  final int? id;
  final int ogrenciId;
  final int okulDenemesiId;
  final int? dogruSayisi;
  final int? yanlisSayisi;
  final double? netSayisi;
  final int? puan;
  final DateTime? tarih;
  final String? aciklama;
  final bool? katildi;

  OgrenciOkulDenemesi({
    this.id,
    required this.ogrenciId,
    required this.okulDenemesiId,
    this.dogruSayisi,
    this.yanlisSayisi,
    this.netSayisi,
    this.puan,
    this.tarih,
    this.aciklama,
    this.katildi,
  });

  factory OgrenciOkulDenemesi.fromJson(Map<String, dynamic> json) {
    // API'den gelen yanıtlarda iki farklı alan adı kullanılıyor - her ikisini de kontrol et
    final examId = json['okul_denemesi_id'] ?? json['okul_deneme_sinavi_id'];

    // Net değeri int, double veya null olabilir, güvenli dönüşüm yapalım
    dynamic rawNet = json['net_sayisi'] ?? json['net'];
    double? netValue;

    if (rawNet != null) {
      // Eğer rawNet bir sayısal değerse (int/double) onu double'a çevirelim
      if (rawNet is int) {
        netValue = rawNet.toDouble();
      } else if (rawNet is double) {
        netValue = rawNet;
      } else if (rawNet is String) {
        // Eğer string ise double'a parse etmeyi deneyelim
        netValue = double.tryParse(rawNet);
      }
    }

    // Diğer alanlar için de güvenli dönüşüm yapalım
    int? dogruSayisi;
    if (json['dogru_sayisi'] != null) {
      if (json['dogru_sayisi'] is int) {
        dogruSayisi = json['dogru_sayisi'];
      } else if (json['dogru_sayisi'] is String) {
        dogruSayisi = int.tryParse(json['dogru_sayisi']);
      }
    }

    int? yanlisSayisi;
    if (json['yanlis_sayisi'] != null) {
      if (json['yanlis_sayisi'] is int) {
        yanlisSayisi = json['yanlis_sayisi'];
      } else if (json['yanlis_sayisi'] is String) {
        yanlisSayisi = int.tryParse(json['yanlis_sayisi']);
      }
    }

    // Öğrenci ID ve Sınav ID için güvenli dönüşüm (bunlar zorunlu alanlar)
    int ogrenciId;
    if (json['ogrenci_id'] is int) {
      ogrenciId = json['ogrenci_id'];
    } else if (json['ogrenci_id'] is String) {
      ogrenciId = int.tryParse(json['ogrenci_id'] as String) ?? 0;
    } else {
      print('UYARI: Öğrenci ID tipi desteklenmiyor: ${json['ogrenci_id']}');
      ogrenciId = 0; // Varsayılan değer atama
    }

    int okulDenemesiId;
    if (examId is int) {
      okulDenemesiId = examId;
    } else if (examId is String) {
      okulDenemesiId = int.tryParse(examId) ?? 0;
    } else {
      print('UYARI: Sınav ID tipi desteklenmiyor: $examId');
      okulDenemesiId = 0; // Varsayılan değer atama
    }

    if (examId == null) {
      print('UYARI: API yanıtında sınav ID bulunamadı: $json');
    }

    return OgrenciOkulDenemesi(
      id: json['id'],
      ogrenciId: ogrenciId,
      okulDenemesiId: okulDenemesiId,
      dogruSayisi: dogruSayisi,
      yanlisSayisi: yanlisSayisi,
      netSayisi: netValue,
      puan: json['puan'],
      tarih: json['tarih'] != null ? DateTime.parse(json['tarih']) : null,
      aciklama: json['aciklama'],
      katildi: json['katildi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ogrenci_id': ogrenciId,
      'okul_denemesi_id': okulDenemesiId,
      if (dogruSayisi != null) 'dogru_sayisi': dogruSayisi,
      if (yanlisSayisi != null) 'yanlis_sayisi': yanlisSayisi,
      if (netSayisi != null) 'net_sayisi': netSayisi,
      if (puan != null) 'puan': puan,
      if (tarih != null) 'tarih': tarih!.toIso8601String(),
      if (aciklama != null) 'aciklama': aciklama,
      if (katildi != null) 'katildi': katildi,
    };
  }

  OgrenciOkulDenemesi copyWith({
    int? id,
    int? ogrenciId,
    int? okulDenemesiId,
    int? dogruSayisi,
    int? yanlisSayisi,
    double? netSayisi,
    int? puan,
    DateTime? tarih,
    String? aciklama,
    bool? katildi,
  }) {
    return OgrenciOkulDenemesi(
      id: id ?? this.id,
      ogrenciId: ogrenciId ?? this.ogrenciId,
      okulDenemesiId: okulDenemesiId ?? this.okulDenemesiId,
      dogruSayisi: dogruSayisi ?? this.dogruSayisi,
      yanlisSayisi: yanlisSayisi ?? this.yanlisSayisi,
      netSayisi: netSayisi ?? this.netSayisi,
      puan: puan ?? this.puan,
      tarih: tarih ?? this.tarih,
      aciklama: aciklama ?? this.aciklama,
      katildi: katildi ?? this.katildi,
    );
  }
}
