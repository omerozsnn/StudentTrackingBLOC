class Unit {
  final int? id;
  final String unitName;
  final int? educationYearId;

  Unit({
    this.id,
    required this.unitName,
    this.educationYearId,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      unitName: json['ünite_adı'] ?? '', // backend sends 'ünite_adı'
      educationYearId: json['egitimOgretimYiliId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ünite_adı': unitName,
      if (educationYearId != null) 'egitimOgretimYiliId': educationYearId,
    };
  }
}
