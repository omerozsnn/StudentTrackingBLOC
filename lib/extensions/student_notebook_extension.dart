import 'package:ogrenci_takip_sistemi/models/student_model.dart';

/// Extension that adds notebook and book tracking functionality to Student model
extension StudentNoteBookBookExtension on Student {
  bool get notebook => _notebook ?? true;
  bool get book => _book ?? true;

  set notebook(bool value) => _notebook = value;
  set book(bool value) => _book = value;

  static final Map<int, bool> _studentNotebooks = {};
  static final Map<int, bool> _studentBooks = {};

  bool? get _notebook => _studentNotebooks[id];
  bool? get _book => _studentBooks[id];

  set _notebook(bool? value) => _studentNotebooks[id] = value!;
  set _book(bool? value) => _studentBooks[id] = value!;
}
