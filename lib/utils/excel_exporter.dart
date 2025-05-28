import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/utils/date_formatter.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';

class ExcelExporter {
  static Future<void> exportStudentsToExcel(
    BuildContext context,
    List<Student> students,
    String? selectedClass,
    {Classes? classObj}
  ) async {
    var excel = xl.Excel.createExcel();
    var sheet = excel['Sınıf Listesi'];

    // Başlıkları ayarla
    final headers = [
      'S.NO',
      'ÖĞRENCİ NO',
      'ADI',
      'SOYADI',
      'CİNSİYETİ',
      'D. TARİHİ',
      'YAŞI',
      'T.C. KİMLİK NO',
      'SINIFI',
      'ŞUBESİ',
      'BABA ADI SOYADI',
      'BABA CEP TELEFONU',
      'BABA MESLEĞİ',
      'BABA İŞ ADRESİ',
      'BABA EĞİTİM DURUMU',
      'VELİ EV ADRESİ AÇIK VE NET OLMALI',
      'ANNE ADI SOYADI',
      'ANNE CEP TEL',
      'ANNE EĞİTİM DURUMU',
      'ÇALIŞIYORSA İŞ TELEFONU',
      'ÇALIŞIYORSA İŞ ADRESİ',
      'ANNE-BABA AYRI-BİRLİKTE',
      'KİMİNLE KALIYOR',
      'Velisi Kim (Anne-Baba)',
      'İlave Açıklama'
    ];

    // Excel başlıklarını ayarla
    for (var i = 0; i < headers.length; i++) {
      var cell = sheet
          .cell(xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
      cell.cellStyle = xl.CellStyle(
        bold: true,
        backgroundColorHex: '#C0C0C0',
        fontColorHex: '#000000',
        horizontalAlign: xl.HorizontalAlign.Left,
        verticalAlign: xl.VerticalAlign.Center,
      );
      if (i == 8 || i == 9) {
        cell.cellStyle = xl.CellStyle(
          bold: true,
          backgroundColorHex: '#FF0000',
          fontColorHex: '#FFFFFF',
          horizontalAlign: xl.HorizontalAlign.Center,
          verticalAlign: xl.VerticalAlign.Center,
        );
      }
    }

    // Öğrenci verilerini ekle
    int rowIndex = 1;
    for (var student in students) {
      var nameParts = (student.adSoyad).split(' ');
      var lastName = nameParts.isNotEmpty ? nameParts.removeLast() : '';
      var firstName = nameParts.join(' ');

      // Sınıf bilgisini ayıkla
      String selectedClassName = '';
      String selectedClassSube = '';

      if (selectedClass != null) {
        var sinifpart = selectedClass.split(' ');
        selectedClassSube = sinifpart.isNotEmpty ? sinifpart.removeLast() : '';
        selectedClassName = sinifpart.join(' ');
      } else if (classObj != null) {
        var sinifpart = classObj.sinifAdi.split(' ');
        selectedClassSube = sinifpart.isNotEmpty ? sinifpart.removeLast() : '';
        selectedClassName = sinifpart.join(' ');
      }

      String cleanValue(dynamic value) {
        return (value == "Bilinmiyor") ? '' : value?.toString() ?? '';
      }

      final row = [
        rowIndex.toString(),
        cleanValue(student.ogrenciNo),
        cleanValue(firstName),
        cleanValue(lastName),
        cleanValue(student.cinsiyeti),
        student.dogumTarihi != null
            ? DateFormatter.convertToLocalFormat(cleanValue(student.dogumTarihi))
            : '',
        cleanValue(student.yasi),
        cleanValue(student.tcKimlik),
        cleanValue(selectedClassName),
        cleanValue(selectedClassSube),
        cleanValue(student.babaAdi),
        cleanValue(student.babaCepTelefonu),
        cleanValue(student.babaMeslegiIsi),
        cleanValue(student.babaIsAdresi),
        cleanValue(student.babaEgitimDurumu),
        cleanValue(student.veliEvAdresi),
        cleanValue(student.anneAdi),
        cleanValue(student.anneCepTelefonu),
        cleanValue(student.anneEgitimDurumu),
        cleanValue(student.anneIsTelefonu),
        cleanValue(student.anneIsAdresi),
        cleanValue(student.anneBabaDurumu),
        cleanValue(student.kiminleKaliyor),
        cleanValue(student.veliKim),
        cleanValue(student.ilaveAciklama),
      ];

      // Excel satırını ekle
      for (var i = 0; i < row.length; i++) {
        var cell = sheet.cell(
            xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        cell.value = row[i];
        cell.cellStyle = xl.CellStyle(
          horizontalAlign: xl.HorizontalAlign.Left,
          verticalAlign: xl.VerticalAlign.Bottom,
        );

        if (i == 8 || i == 9) {
          cell.cellStyle = xl.CellStyle(
            fontColorHex: '#FF0000',
            horizontalAlign: xl.HorizontalAlign.Center,
            verticalAlign: xl.VerticalAlign.Bottom,
          );
        }
      }

      rowIndex++;
    }

    // Sütun genişliklerini ayarla
    final columnWidths = {
      0: 5.0,
      1: 12.0,
      2: 15.0,
      3: 15.0,
      4: 10.0,
      5: 12.0,
      6: 8.0,
      7: 15.0,
      8: 8.0,
      9: 8.0,
      10: 25.0,
      11: 25.0,
      12: 20.0,
      13: 20.0,
      14: 25.0,
      15: 35.0,
      16: 30.0,
      17: 20.0,
      18: 30.0,
      19: 20.0,
      20: 30.0,
      21: 30.0,
      22: 30.0,
      23: 30.0,
      24: 30.0,
    };

    columnWidths.forEach((key, value) {
      sheet.setColWidth(key, value);
    });

    const String filename = 'sinif_listesi.xlsx';

    final String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Excel Kaydet',
      fileName: filename,
      allowedExtensions: ['xlsx'],
      type: FileType.custom,
    );

    if (outputPath != null) {
      try {
        final List<int>? fileBytes = excel.save();
        if (fileBytes != null) {
          File(outputPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);

          UIHelpers.showSuccessMessage(context, 'Excel dosyası kaydedildi: $outputPath');
        }
      } catch (e) {
        UIHelpers.showErrorMessage(context, 'Excel dosyası oluşturulurken bir hata oluştu.');
      }
    }
  }
} 