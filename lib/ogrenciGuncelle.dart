import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'dart:io';
import 'api.dart/studentcontrolApi.dart';
import 'api.dart/classApi.dart' as classApi;

class StudentUpdatePage extends StatefulWidget {
  final Student student;

  const StudentUpdatePage({super.key, required this.student});

  @override
  _StudentUpdatePageState createState() => _StudentUpdatePageState();
}

class _StudentUpdatePageState extends State<StudentUpdatePage> {
  late TextEditingController tcKimlikController;
  late TextEditingController adSoyadController;
  late TextEditingController ogrenciNoController;
  late TextEditingController cinsiyetController;
  late TextEditingController dogumTarihiController;
  late TextEditingController yasiController;
  late TextEditingController babaCepTelefonuController;
  late TextEditingController babaMeslegiController;
  late TextEditingController babaIsAdresiController;
  late TextEditingController babaEgitimDurumuController;
  late TextEditingController veliEvAdresiController;
  late TextEditingController anneCepTelefonuController;
  late TextEditingController anneEgitimDurumuController;
  late TextEditingController anneIsTelefonuController;
  late TextEditingController anneIsAdresiController;
  late TextEditingController anneBabaDurumuController;
  late TextEditingController kiminleKaliyorController;
  late TextEditingController veliKimController;
  late TextEditingController ilaveAciklamaController;
  late TextEditingController anneAdiController;
  late TextEditingController babaAdiController;
  late TextEditingController resimYoluController;

  final StudentApiService apiService =
      StudentApiService(baseUrl: 'http://localhost:3000');
  final classApi.ApiService classService =
      classApi.ApiService(baseUrl: 'http://localhost:3000');

  String? selectedClass;
  List<Map<String, dynamic>> classes = [];

  File? selectedImageFile; // Seçilen resim dosyası

  @override
  @override
  void initState() {
    super.initState();
    // Initialize controllers with student data
    tcKimlikController =
        TextEditingController(text: widget.student.tcKimlik?.toString() ?? '');
    adSoyadController = TextEditingController(text: widget.student.adSoyad);
    ogrenciNoController =
        TextEditingController(text: widget.student.ogrenciNo?.toString() ?? '');
    cinsiyetController =
        TextEditingController(text: widget.student.cinsiyeti ?? '');
    dogumTarihiController =
        TextEditingController(text: widget.student.dogumTarihi ?? '');
    yasiController =
        TextEditingController(text: widget.student.yasi?.toString() ?? '');
    babaCepTelefonuController =
        TextEditingController(text: widget.student.babaCepTelefonu ?? '');
    babaMeslegiController =
        TextEditingController(text: widget.student.babaMeslegiIsi ?? '');
    babaIsAdresiController =
        TextEditingController(text: widget.student.babaIsAdresi ?? '');
    babaEgitimDurumuController =
        TextEditingController(text: widget.student.babaEgitimDurumu ?? '');
    veliEvAdresiController =
        TextEditingController(text: widget.student.veliEvAdresi ?? '');
    anneCepTelefonuController =
        TextEditingController(text: widget.student.anneCepTelefonu ?? '');
    anneEgitimDurumuController =
        TextEditingController(text: widget.student.anneEgitimDurumu ?? '');
    anneIsTelefonuController =
        TextEditingController(text: widget.student.anneIsTelefonu ?? '');
    anneIsAdresiController =
        TextEditingController(text: widget.student.anneIsAdresi ?? '');
    anneBabaDurumuController =
        TextEditingController(text: widget.student.anneBabaDurumu ?? '');
    kiminleKaliyorController =
        TextEditingController(text: widget.student.kiminleKaliyor ?? '');
    veliKimController =
        TextEditingController(text: widget.student.veliKim ?? '');
    ilaveAciklamaController =
        TextEditingController(text: widget.student.ilaveAciklama ?? '');
    anneAdiController =
        TextEditingController(text: widget.student.anneAdi ?? '');
    babaAdiController =
        TextEditingController(text: widget.student.babaAdi ?? '');
    resimYoluController =
        TextEditingController(text: widget.student.resimYolu ?? '');

    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final data = await classService.getClassesForDropdown();
      setState(() {
        classes = List<Map<String, dynamic>>.from(data);
        selectedClass = classes.firstWhere(
          (classItem) =>
              classItem['id'].toString() == widget.student.sinifId.toString(),
          orElse: () => {'sinif_adi': null},
        )['sinif_adi'];
      });
    } catch (error) {
      print('Sınıflar yüklenemedi: $error');
    }
  }

  // Resim seçme işlemi (File Picker ile)
  Future<void> selectStudentImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        selectedImageFile = File(result.files.single.path!);
        resimYoluController.text = result.files.single.path!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resim seçilmedi.')),
      );
    }
  }

  Future<void> updateStudent() async {
    try {
      // Sadece değişen alanları içeren bir map oluştur
      Map<String, dynamic> updateData = {};

      // Sınıf ID'si kontrolü
      final selectedClassId = classes.firstWhere(
        (classItem) => classItem['sinif_adi'] == selectedClass,
        orElse: () => {'id': null},
      )['id'];
      if (selectedClassId != null) {
        updateData['sinif_id'] = selectedClassId.toString();
      }

      // TC Kimlik kontrolü (boş ise null gönder)
      if (tcKimlikController.text.isNotEmpty) {
        updateData['tc_kimlik'] = tcKimlikController.text;
      }

      // Diğer alanların kontrolü
      if (adSoyadController.text != widget.student.adSoyad) {
        updateData['ad_soyad'] = adSoyadController.text;
      }
      if (ogrenciNoController.text != widget.student.ogrenciNo) {
        updateData['ogrenci_no'] = ogrenciNoController.text;
      }
      if (cinsiyetController.text != widget.student.cinsiyeti) {
        updateData['cinsiyeti'] = cinsiyetController.text;
      }

      // Doğum tarihi kontrolü ve formatlaması
      String? formattedDate = formatDate(dogumTarihiController.text);
      if (formattedDate != null &&
          formattedDate != widget.student.dogumTarihi) {
        updateData['dogum_tarihi'] = formattedDate;
      }

      if (yasiController.text.isNotEmpty) {
        final yasi = int.tryParse(yasiController.text);
        if (yasi != null && yasi != widget.student.yasi) {
          updateData['yasi'] = yasi;
        }
      }

      if (babaCepTelefonuController.text != widget.student.babaCepTelefonu) {
        updateData['baba_cep_telefonu'] = babaCepTelefonuController.text;
      }

      if (babaMeslegiController.text != widget.student.babaMeslegiIsi) {
        updateData['baba_meslegi_isi'] = babaMeslegiController.text;
      }

      if (babaIsAdresiController.text != widget.student.babaIsAdresi) {
        updateData['baba_is_adresi'] = babaIsAdresiController.text;
      }

      if (babaEgitimDurumuController.text != widget.student.babaEgitimDurumu) {
        updateData['baba_egitim_durumu'] = babaEgitimDurumuController.text;
      }

      if (veliEvAdresiController.text != widget.student.veliEvAdresi) {
        updateData['veli_ev_adresi'] = veliEvAdresiController.text;
      }

      if (anneCepTelefonuController.text != widget.student.anneCepTelefonu) {
        updateData['anne_cep_telefonu'] = anneCepTelefonuController.text;
      }

      if (anneEgitimDurumuController.text != widget.student.anneEgitimDurumu) {
        updateData['anne_egitim_durumu'] = anneEgitimDurumuController.text;
      }

      if (anneIsAdresiController.text != widget.student.anneIsAdresi) {
        updateData['anne_is_adresi'] = anneIsAdresiController.text;
      }

      if (anneIsTelefonuController.text != widget.student.anneIsTelefonu) {
        updateData['anne_is_telefonu'] = anneIsTelefonuController.text;
      }

      if (anneBabaDurumuController.text != widget.student.anneBabaDurumu) {
        updateData['anne_baba_durumu'] = anneBabaDurumuController.text;
      }

      if (kiminleKaliyorController.text != widget.student.kiminleKaliyor) {
        updateData['kiminle_kaliyor'] = kiminleKaliyorController.text;
      }

      if (veliKimController.text != widget.student.veliKim) {
        updateData['veli_kim'] = veliKimController.text;
      }

      if (ilaveAciklamaController.text != widget.student.ilaveAciklama) {
        updateData['ilave_aciklama'] = ilaveAciklamaController.text;
      }

      // Sadece değişen alanları içeren veriyi gönder
      if (updateData.isNotEmpty) {
        print('Güncellenecek veriler: $updateData'); // Debug için

        await apiService.updateStudent(
          widget.student.id,
          updateData,
        );

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Öğrenci başarıyla güncellendi.'),
        ));

        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Değişiklik yapılmadı.'),
        ));
      }
    } catch (error) {
      print('Öğrenci güncellenemedi: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Güncelleme sırasında hata oluştu: $error'),
      ));
    }
  }

// Tarih formatı için yardımcı fonksiyon
  String? formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    try {
      // Gelen tarih formatını parse et ve ISO formatına çevir
      DateTime date;
      if (dateStr.contains('/')) {
        // DD/MM/YYYY formatı
        List<String> parts = dateStr.split('/');
        date = DateTime(
          int.parse(parts[2]), // yıl
          int.parse(parts[1]), // ay
          int.parse(parts[0]), // gün
        );
      } else if (dateStr.contains('-')) {
        // YYYY-MM-DD formatı
        date = DateTime.parse(dateStr);
      } else {
        throw FormatException('Geçersiz tarih formatı');
      }

      // ISO formatına çevir (YYYY-MM-DD)
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Tarih formatı hatası: $e');
      return null;
    }
  }

  final Color primaryColor = Color(0xFF9DC88D);
  final Color secondaryColor = Color(0xFFB5D4A7);
  final Color accentColor = Color(0xFF86A97D);
  final Color lightColor = Color(0xFFE6EFE3);
  final Color darkColor = Color(0xFF5F7A4C);
  final Color textColor = Color(0xFF374D29);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Güncelle'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightColor, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Temel Bilgiler Kartı
                _buildCard(
                  'Temel Bilgiler',
                  [
                    buildTextField('TC Kimlik', tcKimlikController),
                    buildTextField('Ad Soyad', adSoyadController),
                    buildDropdownField(
                      'Sınıf',
                      selectedClass,
                      classes.map((classItem) {
                        return DropdownMenuItem<String>(
                          value: classItem['sinif_adi'],
                          child: Text(classItem['sinif_adi']),
                        );
                      }).toList(),
                      (newValue) {
                        setState(() {
                          selectedClass = newValue;
                        });
                      },
                    ),
                    buildTextField('Öğrenci No', ogrenciNoController),
                    buildTextField('Cinsiyet', cinsiyetController),
                    buildTextField('Doğum Tarihi', dogumTarihiController),
                    buildTextField('Yaşı', yasiController),
                  ],
                ),
                SizedBox(height: 16),

                // Baba Bilgileri Kartı
                _buildCard(
                  'Baba Bilgileri',
                  [
                    buildTextField('Baba Adı', babaAdiController),
                    buildTextField(
                        'Baba Cep Telefonu', babaCepTelefonuController),
                    buildTextField('Baba Mesleği', babaMeslegiController),
                    buildTextField('Baba İş Adresi', babaIsAdresiController),
                    buildTextField(
                        'Baba Eğitim Durumu', babaEgitimDurumuController),
                  ],
                ),
                SizedBox(height: 16),

                // Anne Bilgileri Kartı
                _buildCard(
                  'Anne Bilgileri',
                  [
                    buildTextField('Anne Adı', anneAdiController),
                    buildTextField(
                        'Anne Cep Telefonu', anneCepTelefonuController),
                    buildTextField(
                        'Anne İş Telefonu', anneIsTelefonuController),
                    buildTextField('Anne İş Adresi', anneIsAdresiController),
                    buildTextField(
                        'Anne Eğitim Durumu', anneEgitimDurumuController),
                  ],
                ),
                SizedBox(height: 16),

                // Veli Bilgileri Kartı
                _buildCard(
                  'Veli/İletişim Bilgileri',
                  [
                    buildTextField(
                        'Anne Baba Durumu', anneBabaDurumuController),
                    buildTextField('Kiminle Kalıyor', kiminleKaliyorController),
                    buildTextField('Velisi Kim', veliKimController),
                    buildTextField('Veli Ev Adresi', veliEvAdresiController),
                    buildTextField('İlave Açıklama', ilaveAciklamaController),
                  ],
                ),
                SizedBox(height: 16),

                // Fotoğraf Kartı
                _buildCard(
                  'Fotoğraf',
                  [
                    // Fotoğraf container'ı
                    Center(
                      // Merkeze almak için
                      child: Container(
                        width: 200, // Sabit genişlik
                        height:
                            200, // Sabit yükseklik - kare görünüm için genişlikle aynı
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: selectedImageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  selectedImageFile!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover, // Resmi container'a sığdır
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Fotoğraf yok'),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Fotoğraf seçme butonu
                    ElevatedButton.icon(
                      onPressed: selectStudentImage,
                      icon: Icon(Icons.photo_camera),
                      label: Text('Fotoğraf Seç'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Güncelleme Butonu
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: updateStudent,
                    icon: Icon(Icons.save),
                    label: Text('Değişiklikleri Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: label == 'Doğum Tarihi'
          ? TextField(
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: secondaryColor),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      controller.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                ),
              ),
              controller: controller,
              readOnly: true,
            )
          : TextField(
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: textColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              controller: controller,
              readOnly: readOnly,
            ),
    );
  }

  Widget buildDropdownField(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
