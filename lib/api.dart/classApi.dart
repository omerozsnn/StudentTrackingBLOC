import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For setting correct MIME type for file upload
import 'dart:io'; // For handling file operations
import '../models/classes_model.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  ApiService({baseUrl});

Future<List<Classes>> getClassesForDropdown() async {
  final response = await http.get(
    Uri.parse('$baseUrl/class/dropdown'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body); 

    // Map each dynamic object to a Classes instance using the fromJson constructor
    List<Classes> classesList = data.map<Classes>((json) {
      return Classes.fromJson(json); // Mapping from json to Class
    }).toList();

    return classesList;
  } else {
    throw Exception('Failed to load classes');
  }
}

Future<List<Classes>> getClassesForScroll({int offset = 0, int limit = 50}) async {
  final response = await http.get(Uri.parse('$baseUrl/class/scroll?offset=$offset&limit=$limit'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    final List<dynamic> dataList = jsonData['data'];

    return dataList
        .map((item) => Classes.fromJson(item as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load classes for scroll');
  }
}


  // Sayfalama ile sınıf listesini getir
  Future<List<Classes>> getClasses({int page = 1, int limit = 10}) async {
    final response =
        await http.get(Uri.parse('$baseUrl/class?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      // Check if the API response has a 'data' field which contains the classes
      if (responseData.containsKey('data') && responseData['data'] is List) {
        final List<dynamic> dataList = responseData['data'];
        return dataList
            .map((item) => Classes.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (responseData is List) {
        // If the response is directly a list
        return (responseData as List)
            .map((item) => Classes.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected API response format');
      }
    } else {
      throw Exception('Failed to load classes with pagination');
    }
  }

  // Yeni sınıf ekle
  Future<void> addClass(Classes classData, {required String sinifAdi}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/class'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(classData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add class');
    }
  }

  // Sınıf id'sine göre sınıf adını getir
  Future<Classes> getClassById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/class/by-id/$id'));

    if (response.statusCode == 200) {
      return Classes.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load class by id');
    }
  }

  // Sınıf güncelle
  Future<void> updateClass(int id, Classes classData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/class/by-id/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(classData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update class');
    }
  }

  // Sınıf adına göre sınıf id'sini getir
  Future<int?> getClassIdByName(String name) async {
    final response =
        await http.get(Uri.parse('$baseUrl/class/id/by-name/$name'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final classItem = Classes.fromJson(data);
      return classItem.id as int?;
    } else {
      throw Exception('Failed to load class by name');
    }
  }

  // Sınıf sil
  Future<void> deleteClass(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/class/by-id/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete class');
    }
  }

  // İsme göre sınıf getir
  Future<List<Classes>> getClassesByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/class/by-name/$name'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Classes.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load classes by name');
    }
  }

  // Excel ile sınıf oluştur
  Future<void> uploadClassExcel(File excelFile) async {
    final mimeType = excelFile.path.endsWith('.xlsx')
        ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        : 'application/vnd.ms-excel';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/class/excel'),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      excelFile.path,
      contentType: MediaType.parse(mimeType),
    ));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to upload class Excel file');
    }
  }
}
