class Misbehaviour {
  final int? id;
  final String yaramazlikAdi;
  final int? egitimOgretimYiliId;

  Misbehaviour({
    this.id,
    required this.yaramazlikAdi,
    this.egitimOgretimYiliId,
  });

  factory Misbehaviour.fromJson(Map<String, dynamic> json) {
    return Misbehaviour(
      id: json['id'],
      yaramazlikAdi: json['yaramazlık_adi'],
      egitimOgretimYiliId: json['egitimOgretimYiliId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['yaramazlık_adi'] = yaramazlikAdi;
    if (egitimOgretimYiliId != null)
      data['egitimOgretimYiliId'] = egitimOgretimYiliId;
    return data;
  }

  @override
  String toString() {
    return 'Misbehaviour(id: $id, yaramazlikAdi: $yaramazlikAdi, egitimOgretimYiliId: $egitimOgretimYiliId)';
  }
}
