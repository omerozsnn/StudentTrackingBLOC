import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

// Import your Student model
// import 'package:your_app/models/student.dart';

class StudentApiService {
  final String baseUrl;

  StudentApiService({required this.baseUrl});

  // Get all students with pagination
  Future<Map<String, dynamic>> getStudents(
      {int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Parse the list of students
      if (responseData['data'] != null) {
        final List<dynamic> studentsJson = responseData['data'];
        final List<Student> students = studentsJson
            .map((studentJson) => Student.fromJson(studentJson))
            .toList();

        // Return with pagination info
        return {
          'totalItems': responseData['totalItems'] ?? 0,
          'totalPages': responseData['totalPages'] ?? 0,
          'currentPage': responseData['currentPage'] ?? page,
          'data': students,
        };
      }
      return responseData;
    } else {
      throw Exception(
          'Failed to load students with pagination: ${response.statusCode}');
    }
  }

  // Get students for dropdown
  Future<List<Student>> getStudentsForDropdown() async {
    final response = await http.get(Uri.parse('$baseUrl/student/dropdown'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> studentsJson = responseData['data'] ?? [];
      return studentsJson
          .map((studentJson) => Student.fromJson(studentJson))
          .toList();
    } else {
      throw Exception(
          'Failed to load students for dropdown: ${response.statusCode}');
    }
  }

  // Get students with infinite scroll
  Future<List<Student>> getStudentsForScroll(
      {int limit = 10, int offset = 0}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/scroll?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> studentsJson = json.decode(response.body);
      return studentsJson
          .map((studentJson) => Student.fromJson(studentJson))
          .toList();
    } else {
      throw Exception(
          'Failed to load students with scroll: ${response.statusCode}');
    }
  }

  // Sort students by number
  Future<List<Student>> sortStudentsByNumber() async {
    final response =
        await http.get(Uri.parse('$baseUrl/student/sort-by-number'));

    if (response.statusCode == 200) {
      final List<dynamic> studentsJson = json.decode(response.body);
      return studentsJson
          .map((studentJson) => Student.fromJson(studentJson))
          .toList();
    } else {
      throw Exception(
          'Failed to sort students by number: ${response.statusCode}');
    }
  }

  // Get student by ID
  Future<Student> getStudentById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/student/$id'));

    if (response.statusCode == 200) {
      return Student.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load student by ID: ${response.statusCode}');
    }
  }

  // Get student number by ID
  Future<String> getStudentNumberById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/student/$id/number'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['ogrenci_no'] ?? '';
    } else {
      throw Exception(
          'Failed to load student number by ID: ${response.statusCode}');
    }
  }

  // Get student name by ID
  Future<String> getStudentNameById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/student/$id/name'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['ad_soyad'] ?? '';
    } else {
      throw Exception(
          'Failed to load student name by ID: ${response.statusCode}');
    }
  }

  // Get students by class ID
  Future<List<Student>> getStudentsByClassId(int classId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/student/class/$classId'));

    if (response.statusCode == 200) {
      final List<dynamic> studentsJson = json.decode(response.body);
      return studentsJson
          .map((studentJson) => Student.fromJson(studentJson))
          .toList();
    } else {
      throw Exception(
          'Failed to load students by class ID: ${response.statusCode}');
    }
  }

  // Get students by class name
  Future<List<Student>> getStudentsByClassName(String className) async {
    try {
      // URL kodlaması yaparak özel karakterleri düzgünce işleyelim
      // NOT: API "6 A" formatında sınıf adlarını bekliyor (tire ile değil boşluk ile)
      final encodedClassName = Uri.encodeComponent(className);
      final url = '$baseUrl/student/class-name/$encodedClassName';

      print('Sınıf adına göre öğrenci isteği: $className');
      print('İstek URL: $url');

      final response = await http.get(Uri.parse(url));
      print('Yanıt kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> studentsJson = jsonDecode(response.body);
        print('${studentsJson.length} öğrenci bulundu');
        return studentsJson.map((json) => Student.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // 404 hatası durumunda (muhtemelen öğrenci bulunamadı) boş liste döndür
        print('Sınıf adına göre öğrenciler bulunamadı: 404');
        // Boş liste dön
        return [];
      } else {
        print(
            'Sınıf adına göre öğrenciler yüklenemedi: ${response.statusCode}');
        throw Exception(
            'Sınıf adına göre öğrenciler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Sınıf adına göre öğrenciler yüklenirken hata oluştu: $e');
      // Hata durumunda boş liste dön
      return [];
    }
  }

  // Get students by name (partial match)
  Future<List<Student>> getStudentsByName(String name) async {
    print('API çağrısı: getStudentsByName - "$name" için arama yapılıyor');
    try {
      final encodedName = Uri.encodeComponent(name);
      final url = '$baseUrl/student/name/$encodedName';
      print('İstek URL: $url');

      final response = await http
          .get(
            Uri.parse(url),
          )
          .timeout(const Duration(seconds: 10));

      print('Yanıt kodu: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> studentsJson = json.decode(response.body);
        print('Yanıt içeriği: ${studentsJson.length} öğrenci bulundu');

        final students = studentsJson
            .map((studentJson) => Student.fromJson(studentJson))
            .toList();
        return students;
      } else {
        final errorMsg =
            'İsme göre öğrenciler yüklenemedi: ${response.statusCode}';
        print(errorMsg);
        if (response.statusCode == 404) {
          // 404 Not Found - Bu isimde öğrenci yok demektir, boş liste döndür
          return [];
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      final errorMsg = 'İsme göre öğrenciler yüklenirken hata: $e';
      print(errorMsg);
      throw Exception(errorMsg);
    }
  }

  // Get student by number
  Future<Student> getStudentByNumber(String studentNumber) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/student/number/${Uri.encodeComponent(studentNumber)}'),
    );

    if (response.statusCode == 200) {
      return Student.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load student by number: ${response.statusCode}');
    }
  }

  // Add a new student
  Future<Student> addStudent(Map<String, dynamic> studentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentData),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return Student.fromJson(responseData['student']);
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add student');
    }
  }

  // Update a student
  Future<Student> updateStudent(
      int id, Map<String, dynamic> studentData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/student/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentData),
    );

    if (response.statusCode == 200) {
      return Student.fromJson(json.decode(response.body));
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);

      if (response.statusCode == 404) {
        throw Exception(errorData['message'] ?? 'Student not found');
      } else if (response.statusCode == 400) {
        throw Exception('Validation errors: ${errorData['errors']}');
      } else {
        throw Exception(errorData['message'] ?? 'Failed to update student');
      }
    }
  }

  // Delete a student
  Future<bool> deleteStudent(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/student/$id'));

    if (response.statusCode == 200) {
      return true;
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['details'] ?? 'Failed to delete student');
    }
  }

  // Upload student image
  Future<String> uploadStudentImage(int id, File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/student/$id/upload-image'),
    );

    // Determine file extension and MIME type
    final fileExtension = imageFile.path.split('.').last.toLowerCase();
    final mimeType = 'image/${fileExtension == 'jpg' ? 'jpeg' : fileExtension}';

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['imageUrl'] ?? '';
    } else {
      throw Exception('Failed to upload student image: ${response.statusCode}');
    }
  }

  // Get student image
  Future<Uint8List?> getStudentImage(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/student/$id/image'));

    if (response.statusCode == 200) {
      return response.bodyBytes; // Direkt byte array olarak döndür
    } else {
      throw Exception('Failed to load student image: ${response.statusCode}');
    }
  }

  // Get student with image
  Future<Student> getStudentWithImage(int id) async {
    try {
      // First get the basic student data
      final studentResponse = await http.get(Uri.parse('$baseUrl/student/$id'));

      if (studentResponse.statusCode != 200) {
        throw Exception(
            'Failed to load student data: ${studentResponse.statusCode}');
      }

      // Parse student data
      final Student student =
          Student.fromJson(json.decode(studentResponse.body));

      try {
        // Try to get the student image, but don't fail if it doesn't exist
        final imageResponse =
            await http.get(Uri.parse('$baseUrl/student/$id/image'));

        if (imageResponse.statusCode == 200) {
          // If image exists, add it to student object
          student.photoData = imageResponse.bodyBytes;
        } else {
          // If no image found (404) or other error, just continue without image
          print(
              'No image found for student $id or error: ${imageResponse.statusCode}');
          // Student will use initials for avatar
        }
      } catch (imageError) {
        // Log image error but continue with student data
        print('Error loading student image: $imageError');
        // Student will use initials for avatar
      }

      return student;
    } catch (e) {
      throw Exception('Failed to load student with image: $e');
    }
  }

  // Import students from Excel
  Future<bool> importStudentsFromExcel(File excelFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/student/import-from-excel'),
    );

    // Determine file extension and MIME type
    final fileExtension = excelFile.path.split('.').last.toLowerCase();
    final mimeType = fileExtension == 'xlsx'
        ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        : 'application/vnd.ms-excel';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        excelFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return true;
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(
          errorData['msg'] ?? 'Failed to import students from Excel');
    }
  }

  // Update students from Excel
  Future<bool> updateStudentsFromExcel(File excelFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/student/update-from-excel'),
      );

      // Determine file extension and MIME type
      final fileExtension = excelFile.path.split('.').last.toLowerCase();
      final mimeType = fileExtension == 'xlsx'
          ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          : 'application/vnd.ms-excel';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          excelFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Check response status
      if (response.statusCode == 200) {
        return true;
      }

      // Handle error cases
      String errorMessage;
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? response.body;
      } catch (e) {
        errorMessage = response.body;
      }

      switch (response.statusCode) {
        case 400:
          throw Exception('Excel dosyası yüklenemedi: $errorMessage');
        case 404:
          throw Exception('Aktif eğitim-öğretim yılı bulunamadı');
        case 415:
          throw Exception('Desteklenmeyen dosya formatı');
        default:
          throw Exception('Excel ile güncelleme başarısız: $errorMessage');
      }
    } catch (e) {
      throw Exception('Excel ile güncelleme sırasında hata: $e');
    }
  }
}
