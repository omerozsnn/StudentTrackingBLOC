import 'package:ogrenci_takip_sistemi/api.dart/teacherFeedbackApi.dart'
    as feedback_api;
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart' as class_api;
import 'package:ogrenci_takip_sistemi/api.dart/studentControlApi.dart'
    as student_api;
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';

class TeacherCommentRepository {
  final feedback_api.ApiService feedbackApiService;
  final class_api.ApiService classApiService;
  final student_api.StudentApiService studentApiService;

  // Add caches to avoid repeated API calls
  final Map<int, List<Map<String, dynamic>>> _studentFeedbackCache = {};
  final Map<String, List<Student>> _studentsCache = {};
  List<TeacherFeedbackOption>? _feedbackOptionsCache;

  TeacherCommentRepository({
    required this.feedbackApiService,
    required this.classApiService,
    required this.studentApiService,
  });

  // Get classes for dropdown
  Future<List<String>> getClassesForDropdown() async {
    try {
      final classData = await classApiService.getClassesForDropdown();
      return classData
          .map<String>((classItem) => classItem.sinifAdi.toString())
          .toList();
    } catch (e) {
      throw Exception('Failed to load classes: $e');
    }
  }

  // Get students by class name
  Future<List<Student>> getStudentsByClassName(String className) async {
    try {
      // Check cache first
      if (_studentsCache.containsKey(className)) {
        print('Using cached students for class: $className');
        return _studentsCache[className]!;
      }

      final students =
          await studentApiService.getStudentsByClassName(className);

      // Cache the result
      _studentsCache[className] = students;

      return students;
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  // Get feedback options for dropdown
  Future<List<TeacherFeedbackOption>> getFeedbackOptions() async {
    try {
      // Use cache if available
      if (_feedbackOptionsCache != null) {
        print(
            'Using cached feedback options: ${_feedbackOptionsCache!.length} options');
        return _feedbackOptionsCache!;
      }

      print('Fetching feedback options from API...');
      final optionsData =
          await feedbackApiService.getTeacherFeedbackOptionsForDropdown();
      print('Raw feedback options data: $optionsData');

      if (optionsData.isEmpty) {
        print('Warning: No feedback options returned from API');
      }

      final options = optionsData.map((item) {
        try {
          print('Processing feedback option: $item');
          return TeacherFeedbackOption(
            id: item['id'],
            gorusMetni: item['gorus_metni'] ?? 'Görüş Yok',
          );
        } catch (e) {
          print('Error processing feedback option item: $e');
          print('Problematic item: $item');
          // Return a placeholder in case of error
          return TeacherFeedbackOption(
            id: 0,
            gorusMetni: 'Hatalı Görüş Verisi',
          );
        }
      }).toList();

      print('Processed ${options.length} feedback options');

      // Cache the result
      _feedbackOptionsCache = options;

      return options;
    } catch (e) {
      print('Error in getFeedbackOptions: $e');
      throw Exception('Failed to load feedback options: $e');
    }
  }

  // Get feedback for a student
  Future<List<Map<String, dynamic>>> getStudentFeedback(int studentId) async {
    try {
      // Check cache first
      if (_studentFeedbackCache.containsKey(studentId)) {
        print('Using cached feedback for student: $studentId');
        return _studentFeedbackCache[studentId]!;
      }

      final feedbackData =
          await feedbackApiService.getTeacherFeedbackByStudentId(studentId);
      List<Map<String, dynamic>> tempFeedbackHistory = [];

      for (var feedback in feedbackData) {
        try {
          final gorusMetni = await feedbackApiService
              .getTeacherFeedbackByOptionId(feedback['gorus_id']);
          tempFeedbackHistory.add({
            'id': feedback['id'],
            'gorus_id': feedback['gorus_id'],
            'gorus_metni': gorusMetni,
            'tarih': feedback['tarih'] ?? feedback['createdAt'],
            'ek_gorus': feedback['ek_gorus'],
          });
        } catch (innerError) {
          tempFeedbackHistory.add({
            'id': feedback['id'],
            'gorus_id': feedback['gorus_id'],
            'gorus_metni': 'Görüş metni yüklenemedi',
            'tarih': feedback['tarih'] ?? feedback['createdAt'],
            'ek_gorus': feedback['ek_gorus'],
          });
        }
      }

      // Cache the result
      _studentFeedbackCache[studentId] = tempFeedbackHistory;

      return tempFeedbackHistory;
    } catch (e) {
      throw Exception('Failed to load student feedback: $e');
    }
  }

  // Add feedback for a student
  Future<void> addFeedback(int studentId, Set<int> feedbackOptionIds) async {
    try {
      for (var gorusId in feedbackOptionIds) {
        final feedbackData = {
          'ogrenci_id': studentId,
          'gorus_id': gorusId,
          'tarih': DateTime.now().toIso8601String(),
        };

        await feedbackApiService.addTeacherFeedback(feedbackData);
      }

      // Clear cache for this student to ensure fresh data next time
      _studentFeedbackCache.remove(studentId);
    } catch (e) {
      throw Exception('Failed to add feedback: $e');
    }
  }

  // Add bulk feedback for multiple students
  Future<Map<String, dynamic>> addBulkFeedback(
      Set<Student> students, Set<int> feedbackOptionIds) async {
    try {
      final List<Map<String, dynamic>> allFeedbackData = [];

      for (var student in students) {
        for (var gorusId in feedbackOptionIds) {
          allFeedbackData.add({
            'ogrenci_id': student.id,
            'gorus_id': gorusId,
            'tarih': DateTime.now().toIso8601String(),
          });
        }

        // Clear cache for each student
        _studentFeedbackCache.remove(student.id);
      }

      await feedbackApiService.addBulkTeacherFeedback(allFeedbackData);

      return {
        'success': true,
        'count': students.length * feedbackOptionIds.length,
      };
    } catch (e) {
      throw Exception('Failed to add bulk feedback: $e');
    }
  }

  // Delete feedback
  Future<void> deleteFeedback(int feedbackId) async {
    try {
      await feedbackApiService.deleteTeacherFeedback(feedbackId);

      // Clear all student feedback cache since we don't know which student this was for
      _studentFeedbackCache.clear();
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }
}
