import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:3000'});

  // Helper method to handle GET requests
  Future<Map<String, dynamic>> _makeGetRequest(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.body}');
    }
  }

  // Helper method to handle POST requests
  Future<void> _makePostRequest(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add data: ${response.body}');
    }
  }

  // Helper method to handle PUT requests
  Future<void> _makePutRequest(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update data: ${response.body}');
    }
  }

  // Helper method to handle DELETE requests
  Future<void> _makeDeleteRequest(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete data: ${response.body}');
    }
  }

  // Teacher Feedback Options (for dropdown)
  Future<List<dynamic>> getTeacherFeedbackOptionsForDropdown() async {
    try {
      print(
          'Requesting teacher feedback options from: $baseUrl/teacher-feedback-options/dropdown');

      final response = await http
          .get(Uri.parse('$baseUrl/teacher-feedback-options/dropdown'));

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Response body length: ${response.body.length}');
        print(
            'Response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');

        final data = json.decode(response.body) as List<dynamic>;
        print('Decoded ${data.length} feedback options');
        return data;
      } else {
        print('Error status ${response.statusCode}: ${response.body}');
        throw Exception(
            'Failed to load teacher feedback options: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getTeacherFeedbackOptionsForDropdown: $e');
      throw Exception('Failed to load teacher feedback options: $e');
    }
  }

  // Add new teacher feedback option
  Future<void> addTeacherFeedbackOption(Map<String, dynamic> optionData) async {
    await _makePostRequest('teacher-feedback-options', optionData);
  }

  // Update teacher feedback option
  Future<void> updateTeacherFeedbackOption(
      int id, Map<String, dynamic> optionData) async {
    await _makePutRequest('teacher-feedback-options/$id', optionData);
  }

  // Delete teacher feedback option
  Future<void> deleteTeacherFeedbackOption(int id) async {
    await _makeDeleteRequest('teacher-feedback-options/$id');
  }

  // ApiService sınıfına eklenecek yeni method:
  Future<void> deleteTeacherFeedback(int id) async {
    await _makeDeleteRequest('teacher-feedbacks/$id');
  }

  Future<String> getTeacherFeedbackByOptionId(int optionId) async {
    try {
      print(
          'Fetching feedback option: $baseUrl/teacher-feedback-options/$optionId'); // Debug için

      final response = await http.get(
        Uri.parse('$baseUrl/teacher-feedback-options/$optionId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}'); // Debug için
      print('Response body: ${response.body}'); // Debug için

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['gorus_metni'] ?? 'Görüş metni bulunamadı';
      } else {
        throw Exception('Görüş seçeneği yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching feedback option: $e');
      throw Exception('Görüş seçeneği yüklenemedi: $e');
    }
  }

  // Get teacher feedbacks grouped by date
  Future<Map<String, List<dynamic>>> getTeacherFeedbackGroupedByDate() async {
    try {
      print(
          'Fetching grouped teacher feedback: $baseUrl/teacher-feedbacks/date/grouped-by-date');

      final response = await http.get(
        Uri.parse('$baseUrl/teacher-feedbacks/date/grouped-by-date'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Parsed grouped feedback response: $jsonResponse');

        // JSON'u doğru formata çevirme
        final Map<String, List<dynamic>> groupedFeedbacks = jsonResponse.map(
          (key, value) => MapEntry(key, List<dynamic>.from(value)),
        );

        return groupedFeedbacks;
      } else {
        throw Exception(
            'Gün bazlı öğretmen görüşleri yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getTeacherFeedbackGroupedByDate: $e');
      throw Exception('Görüşler yüklenirken hata oluştu: $e');
    }
  }

  Future<Map<String, List<dynamic>>> getTeacherFeedbackByStudentIdandDate(
      int studentId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/teacher-feedbacks/student/$studentId/grouped-by-date'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // API'den direkt olarak gruplanmış veri geliyor
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Generic tip dönüşümü yap
        final Map<String, List<dynamic>> groupedFeedbacks = responseData.map(
          (key, value) => MapEntry(key, List<dynamic>.from(value)),
        );

        print('Grouped feedbacks: $groupedFeedbacks'); // Debug için
        return groupedFeedbacks;
      } else {
        throw Exception('Failed to load feedbacks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTeacherFeedbackByStudentIdandDate: $e');
      throw Exception('Görüşler yüklenirken hata oluştu: $e');
    }
  }

  // Get teacher feedback by student ID
  Future<List<Map<String, dynamic>>> getTeacherFeedbackByStudentId(
      int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teacher-feedbacks/student/$studentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Gelen JSON'ı parse edelim
        final List<dynamic> jsonResponse = json.decode(response.body);

        // Her bir görüş için detaylı dönüşüm yapalım
        final List<Map<String, dynamic>> feedbacks = jsonResponse.map((item) {
          try {
            final feedback = {
              'id': item['id'],
              'gorus_id': item['gorus_id'],
              'ogrenci_id': item['ogrenci_id'],
              'gorus_metni': item['gorus_metni'] ?? 'Görüş metni bulunamadı',
              'createdAt': item['createdAt'],
              'updatedAt': item['updatedAt'],
            };
            print('Processed feedback item: $feedback');
            return feedback;
          } catch (e) {
            print('Error processing feedback item: $e');
            print('Problematic item: $item');
            // Hata durumunda bile bir değer döndürelim
            return {
              'id': item['id'] ?? 0,
              'gorus_id': item['gorus_id'] ?? 0,
              'ogrenci_id': item['ogrenci_id'] ?? 0,
              'gorus_metni': 'Veri işlenirken hata oluştu: $e',
              'createdAt':
                  item['createdAt'] ?? DateTime.now().toIso8601String(),
              'updatedAt':
                  item['updatedAt'] ?? DateTime.now().toIso8601String(),
            };
          }
        }).toList();

        print('Final processed feedbacks: $feedbacks');
        return feedbacks;
      } else {
        throw Exception(
            'Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in getTeacherFeedbackByStudentId: $e');
      throw Exception('Görüşler yüklenirken hata oluştu: $e');
    }
  }

  // Add new teacher feedback
  Future<void> addTeacherFeedback(Map<String, dynamic> feedbackData) async {
    await _makePostRequest('teacher-feedbacks', feedbackData);
  }

  // ** New Transfer Method for Teacher Feedback Options **
  Future<void> transferTeacherFeedbackOptions(
      int fromYearId, int toYearId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teacher-feedback-options/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fromYearId': fromYearId,
        'toYearId': toYearId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to transfer teacher feedback options: ${response.body}');
    }
  }

  Future<void> addBulkTeacherFeedback(
      List<Map<String, dynamic>> feedbackDataList) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teacher-feedbacks/bulk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'studentFeedbacks': feedbackDataList}),
      );

      if (response.statusCode != 201) {
        // API'den gelen hata mesajını parse et
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['error'] ?? 'Toplu görüş ekleme başarısız oldu');
      }

      // İşlem başarılı, response'u parse et
      final responseData = json.decode(response.body);
      print('Bulk insert successful: ${responseData['message']}');

      // Başarılı ve başarısız işlemlerin sayısını kontrol et
      if (responseData.containsKey('data')) {
        final successCount = responseData['data'].length;
        print('Successfully added $successCount feedbacks');
      }
    } catch (e) {
      print('Error in addBulkTeacherFeedback: $e');
      throw Exception('Toplu görüş ekleme sırasında hata oluştu: $e');
    }
  }

  // Progress takibi için bulk teacher feedback ekleme metodu (alternatif versiyon)
  Future<Map<String, dynamic>> addBulkTeacherFeedbackWithProgress(
    List<Map<String, dynamic>> feedbackDataList,
    Function(int completed, int total) onProgress,
  ) async {
    try {
      final totalCount = feedbackDataList.length;
      var successCount = 0;
      var failureCount = 0;
      final failedItems = <Map<String, dynamic>>[];

      // Her bir feedback için ayrı request gönder (progress takibi için)
      for (var i = 0; i < feedbackDataList.length; i++) {
        try {
          await addTeacherFeedback(feedbackDataList[i]);
          successCount++;
        } catch (e) {
          failureCount++;
          failedItems.add({
            'data': feedbackDataList[i],
            'error': e.toString(),
          });
        }

        // Progress callback'i çağır
        onProgress(i + 1, totalCount);
      }

      return {
        'success': successCount,
        'failure': failureCount,
        'failedItems': failedItems,
      };
    } catch (e) {
      print('Error in addBulkTeacherFeedbackWithProgress: $e');
      throw Exception('Toplu görüş ekleme sırasında hata oluştu: $e');
    }
  }
}
