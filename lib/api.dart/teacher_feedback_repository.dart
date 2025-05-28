import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_model.dart';
import 'package:ogrenci_takip_sistemi/api.dart/teacherFeedbackApi.dart';

class TeacherFeedbackRepository {
  final ApiService apiService;

  TeacherFeedbackRepository({required this.apiService});

  // Get teacher feedback options for dropdown
  Future<List<TeacherFeedbackOption>> getTeacherFeedbackOptions() async {
    try {
      final List<dynamic> data =
          await apiService.getTeacherFeedbackOptionsForDropdown();
      return data.map((json) => TeacherFeedbackOption.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load teacher feedback options: $e');
    }
  }

  // Add a new teacher feedback option
  Future<void> addTeacherFeedbackOption(String gorusMetni) async {
    try {
      await apiService.addTeacherFeedbackOption({'gorus_metni': gorusMetni});
    } catch (e) {
      throw Exception('Failed to add teacher feedback option: $e');
    }
  }

  // Update a teacher feedback option
  Future<void> updateTeacherFeedbackOption(int id, String gorusMetni) async {
    try {
      await apiService
          .updateTeacherFeedbackOption(id, {'gorus_metni': gorusMetni});
    } catch (e) {
      throw Exception('Failed to update teacher feedback option: $e');
    }
  }

  // Delete a teacher feedback option
  Future<void> deleteTeacherFeedbackOption(int id) async {
    try {
      await apiService.deleteTeacherFeedbackOption(id);
    } catch (e) {
      throw Exception('Failed to delete teacher feedback option: $e');
    }
  }

  // Get teacher feedbacks grouped by date
  Future<Map<String, List<TeacherFeedback>>>
      getTeacherFeedbackGroupedByDate() async {
    try {
      final Map<String, List<dynamic>> groupedData =
          await apiService.getTeacherFeedbackGroupedByDate();

      // Convert each entry to TeacherFeedback objects
      final Map<String, List<TeacherFeedback>> result = {};
      groupedData.forEach((date, feedbacks) {
        result[date] = feedbacks
            .map((feedback) => TeacherFeedback.fromJson(feedback))
            .toList();
      });

      return result;
    } catch (e) {
      throw Exception('Failed to load grouped teacher feedbacks: $e');
    }
  }

  // Get teacher feedbacks for a specific student
  Future<List<TeacherFeedback>> getTeacherFeedbacksByStudentId(
      int studentId) async {
    try {
      final List<Map<String, dynamic>> data =
          await apiService.getTeacherFeedbackByStudentId(studentId);
      return data.map((json) => TeacherFeedback.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load teacher feedbacks for student: $e');
    }
  }

  // Get teacher feedbacks for a specific student grouped by date
  Future<Map<String, List<TeacherFeedback>>>
      getTeacherFeedbacksByStudentIdGroupedByDate(int studentId) async {
    try {
      final Map<String, List<dynamic>> groupedData =
          await apiService.getTeacherFeedbackByStudentIdandDate(studentId);

      // Convert each entry to TeacherFeedback objects
      final Map<String, List<TeacherFeedback>> result = {};
      groupedData.forEach((date, feedbacks) {
        result[date] = feedbacks
            .map((feedback) => TeacherFeedback.fromJson(feedback))
            .toList();
      });

      return result;
    } catch (e) {
      throw Exception(
          'Failed to load grouped teacher feedbacks for student: $e');
    }
  }

  // Add a new teacher feedback
  Future<void> addTeacherFeedback(int gorusId, int ogrenciId) async {
    try {
      await apiService.addTeacherFeedback({
        'gorus_id': gorusId,
        'ogrenci_id': ogrenciId,
      });
    } catch (e) {
      throw Exception('Failed to add teacher feedback: $e');
    }
  }

  // Add multiple teacher feedbacks at once
  Future<void> addBulkTeacherFeedback(
      List<Map<String, dynamic>> feedbacks) async {
    try {
      await apiService.addBulkTeacherFeedback(feedbacks);
    } catch (e) {
      throw Exception('Failed to add bulk teacher feedbacks: $e');
    }
  }

  // Delete a teacher feedback
  Future<void> deleteTeacherFeedback(int id) async {
    try {
      await apiService.deleteTeacherFeedback(id);
    } catch (e) {
      throw Exception('Failed to delete teacher feedback: $e');
    }
  }
}
