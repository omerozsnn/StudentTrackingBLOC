class Grade {
  final int? id;
  final int ogrenciId;
  final int sinifDersleriId;
  final int donem;
  final double? sinav1;
  final double? sinav2;
  final double? sinav3;
  final double? sinav4;
  final double? dersEtkinlikleri1;
  final double? dersEtkinlikleri2;
  final double? dersEtkinlikleri3;
  final double? dersEtkinlikleri4;
  final double? dersEtkinlikleri5;
  final double? proje1;
  final double? proje2;
  final double? donemPuani;

  final String? ogrenciAdi;
  final String? ogrenciNo;

  final String? dersAdi;
  final int? sinifId;
  final String? sinifAdi;

  final int? sinifSirasi;

  Grade({
    this.id,
    required this.ogrenciId,
    required this.sinifDersleriId,
    required this.donem,
    this.sinav1,
    this.sinav2,
    this.sinav3,
    this.sinav4,
    this.dersEtkinlikleri1,
    this.dersEtkinlikleri2,
    this.dersEtkinlikleri3,
    this.dersEtkinlikleri4,
    this.dersEtkinlikleri5,
    this.proje1,
    this.proje2,
    this.donemPuani,
    this.ogrenciAdi,
    this.ogrenciNo,
    this.dersAdi,
    this.sinifId,
    this.sinifAdi,
    this.sinifSirasi,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      ogrenciId: json['ogrenci_id'],
      sinifDersleriId: json['sinif_dersleri_id'],
      donem: json['donem'],
      sinav1: json['sinav1']?.toDouble(),
      sinav2: json['sinav2']?.toDouble(),
      sinav3: json['sinav3']?.toDouble(),
      sinav4: json['sinav4']?.toDouble(),
      dersEtkinlikleri1: json['ders_etkinlikleri1']?.toDouble(),
      dersEtkinlikleri2: json['ders_etkinlikleri2']?.toDouble(),
      dersEtkinlikleri3: json['ders_etkinlikleri3']?.toDouble(),
      dersEtkinlikleri4: json['ders_etkinlikleri4']?.toDouble(),
      dersEtkinlikleri5: json['ders_etkinlikleri5']?.toDouble(),
      proje1: json['proje1']?.toDouble(),
      proje2: json['proje2']?.toDouble(),
      donemPuani: json['donem_puani']?.toDouble(),
      ogrenciAdi: json['ogrenci_adi'],
      ogrenciNo: json['ogrenci_no'],
      dersAdi: json['ders_adi'],
      sinifId: json['sinif_id'],
      sinifAdi: json['sinif_adi'],
      sinifSirasi: json['sinif_sirasi'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'ogrenci_id': ogrenciId,
      'sinif_dersleri_id': sinifDersleriId,
      'donem': donem,
    };

    if (id != null) data['id'] = id;
    if (sinav1 != null) data['sinav1'] = sinav1;
    if (sinav2 != null) data['sinav2'] = sinav2;
    if (sinav3 != null) data['sinav3'] = sinav3;
    if (sinav4 != null) data['sinav4'] = sinav4;
    if (dersEtkinlikleri1 != null)
      data['ders_etkinlikleri1'] = dersEtkinlikleri1;
    if (dersEtkinlikleri2 != null)
      data['ders_etkinlikleri2'] = dersEtkinlikleri2;
    if (dersEtkinlikleri3 != null)
      data['ders_etkinlikleri3'] = dersEtkinlikleri3;
    if (dersEtkinlikleri4 != null)
      data['ders_etkinlikleri4'] = dersEtkinlikleri4;
    if (dersEtkinlikleri5 != null)
      data['ders_etkinlikleri5'] = dersEtkinlikleri5;
    if (proje1 != null) data['proje1'] = proje1;
    if (proje2 != null) data['proje2'] = proje2;
    if (donemPuani != null) data['donem_puani'] = donemPuani;

    return data;
  }

  Grade copyWith({
    int? id,
    int? ogrenciId,
    int? sinifDersleriId,
    int? donem,
    double? sinav1,
    double? sinav2,
    double? sinav3,
    double? sinav4,
    double? dersEtkinlikleri1,
    double? dersEtkinlikleri2,
    double? dersEtkinlikleri3,
    double? dersEtkinlikleri4,
    double? dersEtkinlikleri5,
    double? proje1,
    double? proje2,
    double? donemPuani,
    String? ogrenciAdi,
    String? ogrenciNo,
    String? dersAdi,
    int? sinifId,
    String? sinifAdi,
    int? sinifSirasi,
  }) {
    return Grade(
      id: id ?? this.id,
      ogrenciId: ogrenciId ?? this.ogrenciId,
      sinifDersleriId: sinifDersleriId ?? this.sinifDersleriId,
      donem: donem ?? this.donem,
      sinav1: sinav1 ?? this.sinav1,
      sinav2: sinav2 ?? this.sinav2,
      sinav3: sinav3 ?? this.sinav3,
      sinav4: sinav4 ?? this.sinav4,
      dersEtkinlikleri1: dersEtkinlikleri1 ?? this.dersEtkinlikleri1,
      dersEtkinlikleri2: dersEtkinlikleri2 ?? this.dersEtkinlikleri2,
      dersEtkinlikleri3: dersEtkinlikleri3 ?? this.dersEtkinlikleri3,
      dersEtkinlikleri4: dersEtkinlikleri4 ?? this.dersEtkinlikleri4,
      dersEtkinlikleri5: dersEtkinlikleri5 ?? this.dersEtkinlikleri5,
      proje1: proje1 ?? this.proje1,
      proje2: proje2 ?? this.proje2,
      donemPuani: donemPuani ?? this.donemPuani,
      ogrenciAdi: ogrenciAdi ?? this.ogrenciAdi,
      ogrenciNo: ogrenciNo ?? this.ogrenciNo,
      dersAdi: dersAdi ?? this.dersAdi,
      sinifId: sinifId ?? this.sinifId,
      sinifAdi: sinifAdi ?? this.sinifAdi,
      sinifSirasi: sinifSirasi ?? this.sinifSirasi,
    );
  }
}

class StudentSemesterGrades {
  final String ogrenciAdi;
  final String ogrenciNo;
  final String egitimOgretimYili;
  final int donem;
  final List<Grade> dersler;

  StudentSemesterGrades({
    required this.ogrenciAdi,
    required this.ogrenciNo,
    required this.egitimOgretimYili,
    required this.donem,
    required this.dersler,
  });

  factory StudentSemesterGrades.fromJson(Map<String, dynamic> json) {
    var dersList = List<Map<String, dynamic>>.from(json['dersler']);

    return StudentSemesterGrades(
      ogrenciAdi: json['ogrenci_adi'],
      ogrenciNo: json['ogrenci_no'],
      egitimOgretimYili: json['egitim_ogretim_yili'],
      donem: json['donem'],
      dersler: dersList.map((dersData) => Grade.fromJson(dersData)).toList(),
    );
  }
}

class CourseClassGrades {
  final int courseClassId;
  final String dersAdi;
  final double sinifOrtalama;
  final List<StudentGradeRanking> ogrenciler;

  CourseClassGrades({
    required this.courseClassId,
    required this.dersAdi,
    required this.sinifOrtalama,
    required this.ogrenciler,
  });

  factory CourseClassGrades.fromJson(Map<String, dynamic> json) {
    var studentList = List<Map<String, dynamic>>.from(json['ogrenciler']);

    return CourseClassGrades(
      courseClassId: json['courseClass_id'],
      dersAdi: json['ders_adi'],
      sinifOrtalama: json['sinif_ortalama']?.toDouble() ?? 0.0,
      ogrenciler: studentList
          .map((data) => StudentGradeRanking.fromJson(data))
          .toList(),
    );
  }
}

class StudentGradeRanking {
  final int ogrenciId;
  final String ogrenciAdi;
  final String ogrenciNo;
  final double? donemPuani;
  final int sinifSirasi;

  StudentGradeRanking({
    required this.ogrenciId,
    required this.ogrenciAdi,
    required this.ogrenciNo,
    this.donemPuani,
    required this.sinifSirasi,
  });

  factory StudentGradeRanking.fromJson(Map<String, dynamic> json) {
    return StudentGradeRanking(
      ogrenciId: json['ogrenci_id'],
      ogrenciAdi: json['ogrenci_adi'],
      ogrenciNo: json['ogrenci_no'],
      donemPuani: json['donem_puani']?.toDouble(),
      sinifSirasi: json['sinif_sirasi'],
    );
  }
}

class ClassGradesByCourse {
  final int sinifId;
  final int donem;
  final Map<String, CourseSummary> dersler;

  ClassGradesByCourse({
    required this.sinifId,
    required this.donem,
    required this.dersler,
  });

  factory ClassGradesByCourse.fromJson(Map<String, dynamic> json) {
    Map<String, CourseSummary> coursesMap = {};
    Map<String, dynamic> coursesData =
        Map<String, dynamic>.from(json['dersler']);

    coursesData.forEach((key, value) {
      coursesMap[key] = CourseSummary.fromJson(value);
    });

    return ClassGradesByCourse(
      sinifId: json['sinif_id'],
      donem: json['donem'],
      dersler: coursesMap,
    );
  }
}

class CourseSummary {
  final String dersAdi;
  final double sinifOrtalama;
  final List<StudentGradeRanking> ogrenciler;

  CourseSummary({
    required this.dersAdi,
    required this.sinifOrtalama,
    required this.ogrenciler,
  });

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    var studentList = List<Map<String, dynamic>>.from(json['ogrenciler']);

    return CourseSummary(
      dersAdi: json['ders_adi'],
      sinifOrtalama: json['sinif_ortalama']?.toDouble() ?? 0.0,
      ogrenciler: studentList
          .map((data) => StudentGradeRanking.fromJson(data))
          .toList(),
    );
  }
}
