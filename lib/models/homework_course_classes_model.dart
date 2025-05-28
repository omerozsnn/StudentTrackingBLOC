class HomeworkCourseClass {
  final int? id;
  final int odevId;
  final int sinifDersleriId;
  final int? egitimOgretimYiliId;

  HomeworkCourseClass({
    this.id,
    required this.odevId,
    required this.sinifDersleriId,
    this.egitimOgretimYiliId,
  });

  // JSON'dan model oluşturma
  factory HomeworkCourseClass.fromJson(Map<String, dynamic> json) {
    return HomeworkCourseClass(
      id: json['id'],
      odevId: json['odev_id'],
      sinifDersleriId: json['sinif_dersleri_id'],
      egitimOgretimYiliId: json['egitimOgretimYiliId'],
    );
  }

  // Modelden JSON oluşturma
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['odev_id'] = odevId;
    data['sinif_dersleri_id'] = sinifDersleriId;
    if (egitimOgretimYiliId != null)
      data['egitimOgretimYiliId'] = egitimOgretimYiliId;
    return data;
  }

  @override
  String toString() {
    return 'HomeworkCourseClass(id: $id, odevId: $odevId, sinifDersleriId: $sinifDersleriId, egitimOgretimYiliId: $egitimOgretimYiliId)';
  }
}
