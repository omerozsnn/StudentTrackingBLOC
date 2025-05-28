import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/utils/snackbar_helper.dart';

class ExcelHelper {
  static Future<File?> pickExcelFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      } else {
        // User canceled the picker
        return null;
      }
    } catch (e) {
      SnackbarHelper.showErrorSnackBar(
          context, 'Excel dosyası seçilirken hata oluştu: $e');
      return null;
    }
  }

  static bool isValidExcelFile(File file) {
    final String extension = file.path.split('.').last.toLowerCase();
    return extension == 'xlsx' || extension == 'xls';
  }

  static String getReadableFileSize(File file) {
    final int bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1048576) {
      final kb = (bytes / 1024).toStringAsFixed(2);
      return '$kb KB';
    } else {
      final mb = (bytes / 1048576).toStringAsFixed(2);
      return '$mb MB';
    }
  }

  static Future<void> showExcelUploadDialog({
    required BuildContext context,
    required String title,
    required String message,
    required Function(File) onUpload,
  }) async {
    File? excelFile = await pickExcelFile(context);

    if (excelFile != null) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.description, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        excelFile.path.split('/').last,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Boyut: ${getReadableFileSize(excelFile)}'),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('İptal'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Yükle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onUpload(excelFile);
                },
              ),
            ],
          ),
        );
      }
    }
  }
}
