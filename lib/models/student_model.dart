import 'dart:typed_data';

class Student {
  final int id;
  final dynamic tcKimlik;
  final String adSoyad;
  final int sinifId;
  final String? ogrenciNo;
  final String? anneAdi;
  final String? babaAdi;
  final String? resimYolu;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? cinsiyeti;
  final String? dogumTarihi;
  final int? yasi;
  final String? babaCepTelefonu;
  final String? babaMeslegiIsi;
  final String? babaIsAdresi;
  final String? babaEgitimDurumu;
  final String? veliEvAdresi;
  final String? anneCepTelefonu;
  final String? anneEgitimDurumu;
  final String? anneIsTelefonu;
  final String? anneIsAdresi;
  final String? anneBabaDurumu;
  final String? kiminleKaliyor;
  final String? veliKim;
  final String? ilaveAciklama;

  // Adding image URL for frontend display
  String? imageUrl;
  
  // Adding photo data for in-memory image caching
  Uint8List? photoData;

  Student({
    required this.id,
    this.tcKimlik,
    required this.adSoyad,
    required this.sinifId,
    this.ogrenciNo,
    this.anneAdi,
    this.babaAdi,
    this.resimYolu,
    this.createdAt,
    this.updatedAt,
    this.cinsiyeti,
    this.dogumTarihi,
    this.yasi,
    this.babaCepTelefonu,
    this.babaMeslegiIsi,
    this.babaIsAdresi,
    this.babaEgitimDurumu,
    this.veliEvAdresi,
    this.anneCepTelefonu,
    this.anneEgitimDurumu,
    this.anneIsTelefonu,
    this.anneIsAdresi,
    this.anneBabaDurumu,
    this.kiminleKaliyor,
    this.veliKim,
    this.ilaveAciklama,
    this.imageUrl,
    this.photoData,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      tcKimlik: json['tc_kimlik'],
      adSoyad: json['ad_soyad'],
      sinifId: json['sinif_id'],
      ogrenciNo: json['ogrenci_no'],
      anneAdi: json['anne_adi'],
      babaAdi: json['baba_adi'],
      resimYolu: json['resim_yolu'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      cinsiyeti: json['cinsiyeti'],
      dogumTarihi: json['dogum_tarihi'],
      yasi: json['yasi'],
      babaCepTelefonu: json['baba_cep_telefonu'],
      babaMeslegiIsi: json['baba_meslegi_isi'],
      babaIsAdresi: json['baba_is_adresi'],
      babaEgitimDurumu: json['baba_egitim_durumu'],
      veliEvAdresi: json['veli_ev_adresi'],
      anneCepTelefonu: json['anne_cep_telefonu'],
      anneEgitimDurumu: json['anne_egitim_durumu'],
      anneIsTelefonu: json['anne_is_telefonu'],
      anneIsAdresi: json['anne_is_adresi'],
      anneBabaDurumu: json['anne_baba_durumu'],
      kiminleKaliyor: json['kiminle_kaliyor'],
      veliKim: json['veli_kim'],
      ilaveAciklama: json['ilave_aciklama'],
      imageUrl: json['imageUrl'],
      photoData: json['photoData'] != null ? Uint8List.fromList(json['photoData']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'tc_kimlik': tcKimlik,
      'ad_soyad': adSoyad,
      'sinif_id': sinifId,
      'ogrenci_no': ogrenciNo,
      'anne_adi': anneAdi,
      'baba_adi': babaAdi,
      'resim_yolu': resimYolu,
      'cinsiyeti': cinsiyeti,
      'dogum_tarihi': dogumTarihi,
      'yasi': yasi,
      'baba_cep_telefonu': babaCepTelefonu,
      'baba_meslegi_isi': babaMeslegiIsi,
      'baba_is_adresi': babaIsAdresi,
      'baba_egitim_durumu': babaEgitimDurumu,
      'veli_ev_adresi': veliEvAdresi,
      'anne_cep_telefonu': anneCepTelefonu,
      'anne_egitim_durumu': anneEgitimDurumu,
      'anne_is_telefonu': anneIsTelefonu,
      'anne_is_adresi': anneIsAdresi,
      'anne_baba_durumu': anneBabaDurumu,
      'kiminle_kaliyor': kiminleKaliyor,
      'veli_kim': veliKim,
      'ilave_aciklama': ilaveAciklama,
    };

    // Only include imageUrl if it's not null
    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }

    // Only include photoData if it's not null
    if (photoData != null) {
      data['photoData'] = photoData;
    }

    return data;
  }

  // Create a copy of this Student with the given field values updated
  Student copyWith({
    int? id,
    dynamic tcKimlik,
    String? adSoyad,
    int? sinifId,
    String? ogrenciNo,
    String? anneAdi,
    String? babaAdi,
    String? resimYolu,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cinsiyeti,
    String? dogumTarihi,
    int? yasi,
    String? babaCepTelefonu,
    String? babaMeslegiIsi,
    String? babaIsAdresi,
    String? babaEgitimDurumu,
    String? veliEvAdresi,
    String? anneCepTelefonu,
    String? anneEgitimDurumu,
    String? anneIsTelefonu,
    String? anneIsAdresi,
    String? anneBabaDurumu,
    String? kiminleKaliyor,
    String? veliKim,
    String? ilaveAciklama,
    String? imageUrl,
    Uint8List? photoData,
  }) {
    return Student(
      id: id ?? this.id,
      tcKimlik: tcKimlik ?? this.tcKimlik,
      adSoyad: adSoyad ?? this.adSoyad,
      sinifId: sinifId ?? this.sinifId,
      ogrenciNo: ogrenciNo ?? this.ogrenciNo,
      anneAdi: anneAdi ?? this.anneAdi,
      babaAdi: babaAdi ?? this.babaAdi,
      resimYolu: resimYolu ?? this.resimYolu,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cinsiyeti: cinsiyeti ?? this.cinsiyeti,
      dogumTarihi: dogumTarihi ?? this.dogumTarihi,
      yasi: yasi ?? this.yasi,
      babaCepTelefonu: babaCepTelefonu ?? this.babaCepTelefonu,
      babaMeslegiIsi: babaMeslegiIsi ?? this.babaMeslegiIsi,
      babaIsAdresi: babaIsAdresi ?? this.babaIsAdresi,
      babaEgitimDurumu: babaEgitimDurumu ?? this.babaEgitimDurumu,
      veliEvAdresi: veliEvAdresi ?? this.veliEvAdresi,
      anneCepTelefonu: anneCepTelefonu ?? this.anneCepTelefonu,
      anneEgitimDurumu: anneEgitimDurumu ?? this.anneEgitimDurumu,
      anneIsTelefonu: anneIsTelefonu ?? this.anneIsTelefonu,
      anneIsAdresi: anneIsAdresi ?? this.anneIsAdresi,
      anneBabaDurumu: anneBabaDurumu ?? this.anneBabaDurumu,
      kiminleKaliyor: kiminleKaliyor ?? this.kiminleKaliyor,
      veliKim: veliKim ?? this.veliKim,
      ilaveAciklama: ilaveAciklama ?? this.ilaveAciklama,
      imageUrl: imageUrl ?? this.imageUrl,
      photoData: photoData ?? this.photoData,
    );
  }

  // Helper method to create a new student (without ID, createdAt, updatedAt)
  static Map<String, dynamic> createStudentPayload({
    required String adSoyad,
    required int sinifId,
    dynamic tcKimlik,
    String? ogrenciNo,
    String? anneAdi,
    String? babaAdi,
    String? cinsiyeti,
    String? dogumTarihi,
    int? yasi,
    String? babaCepTelefonu,
    String? babaMeslegiIsi,
    String? babaIsAdresi,
    String? babaEgitimDurumu,
    String? veliEvAdresi,
    String? anneCepTelefonu,
    String? anneEgitimDurumu,
    String? anneIsTelefonu,
    String? anneIsAdresi,
    String? anneBabaDurumu,
    String? kiminleKaliyor,
    String? veliKim,
    String? ilaveAciklama,
  }) {
    return {
      'ad_soyad': adSoyad,
      'sinif_id': sinifId,
      'tc_kimlik': tcKimlik,
      'ogrenci_no': ogrenciNo,
      'anne_adi': anneAdi,
      'baba_adi': babaAdi,
      'cinsiyeti': cinsiyeti,
      'dogum_tarihi': dogumTarihi,
      'yasi': yasi,
      'baba_cep_telefonu': babaCepTelefonu,
      'baba_meslegi_isi': babaMeslegiIsi,
      'baba_is_adresi': babaIsAdresi,
      'baba_egitim_durumu': babaEgitimDurumu,
      'veli_ev_adresi': veliEvAdresi,
      'anne_cep_telefonu': anneCepTelefonu,
      'anne_egitim_durumu': anneEgitimDurumu,
      'anne_is_telefonu': anneIsTelefonu,
      'anne_is_adresi': anneIsAdresi,
      'anne_baba_durumu': anneBabaDurumu,
      'kiminle_kaliyor': kiminleKaliyor,
      'veli_kim': veliKim,
      'ilave_aciklama': ilaveAciklama,
    };
  }

  // toString metodunu override ederek binary verilerin konsola yazdırılmasını engelleyelim
  @override
  String toString() {
    return 'Student{id: $id, adSoyad: $adSoyad, ogrenciNo: $ogrenciNo, sinifId: $sinifId, hasPhoto: ${photoData != null}}';
  }
}
