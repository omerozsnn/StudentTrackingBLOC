import '../../models/homework_tracking_model.dart';
import '../../api.dart/homeworkTrackingControlApi.dart';

class HomeworkTrackingRepository {
  final ApiService _apiService;

  HomeworkTrackingRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Get all homework tracking records
  Future<List<HomeworkTracking>> getAllHomeworkTracking() async {
    try {
      final trackingData = await _apiService.getAllHomeworkTracking();
      return trackingData
          .map((data) => HomeworkTracking.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to load homework tracking records: $e');
    }
  }

  // Get homework tracking by ID
  Future<HomeworkTracking> getHomeworkTrackingById(int id) async {
    try {
      final trackingData = await _apiService.getHomeworkTrackingById(id);
      return HomeworkTracking.fromJson(trackingData);
    } catch (e) {
      throw Exception('Failed to load homework tracking: $e');
    }
  }

  // Add a new homework tracking
  Future<void> addHomeworkTracking(HomeworkTracking tracking) async {
    try {
      await _apiService.addHomeworkTracking(tracking.toJson());
    } catch (e) {
      throw Exception('Failed to add homework tracking: $e');
    }
  }

  // Update an existing homework tracking
  Future<void> updateHomeworkTracking(HomeworkTracking tracking) async {
    if (tracking.id == null) {
      throw Exception('Cannot update homework tracking without ID');
    }

    try {
      await _apiService.updateHomeworkTracking(tracking.id!, tracking.toJson());
    } catch (e) {
      throw Exception('Failed to update homework tracking: $e');
    }
  }

  // Delete a homework tracking
  Future<void> deleteHomeworkTracking(int id) async {
    try {
      await _apiService.deleteHomeworkTracking(id);
    } catch (e) {
      throw Exception('Failed to delete homework tracking: $e');
    }
  }

  // Get tracking records by student homework ID
  Future<List<HomeworkTracking>> getTrackingByStudentHomeworkId(
      int studentHomeworkId) async {
    try {
      final trackingData = await _apiService
          .getHomeworkTrackingByStudentHomeworkId(studentHomeworkId);
      return trackingData
          .map((data) => HomeworkTracking.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception(
          'Failed to load homework tracking by student homework ID: $e');
    }
  }

  // Bulk upsert homework tracking records
  Future<void> bulkUpsertHomeworkTracking(
      List<HomeworkTracking> trackingList) async {
    try {
      final bulkData =
          trackingList.map((tracking) => tracking.toJson()).toList();
      await _apiService.bulkUpsertHomeworkTracking(bulkData);
    } catch (e) {
      throw Exception('Failed to bulk upsert homework tracking: $e');
    }
  }

  // Bulk get homework tracking records
  Future<List<HomeworkTracking>> bulkGetHomeworkTracking(
      List<int> studentHomeworkIds) async {
    try {
      final trackingData =
          await _apiService.bulkGetHomeworkTracking(studentHomeworkIds);
      return trackingData
          .map((data) => HomeworkTracking.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to bulk get homework tracking: $e');
    }
  }

  // Bulk get homework tracking records by homework
  Future<List<HomeworkTracking>> bulkGetHomeworkTrackingForHomework(
      List<int> studentIds, int homeworkId) async {
    try {
      final trackingData = await _apiService.bulkGetHomeworkTrackingForHomework(
          studentIds, homeworkId);
      return trackingData
          .map((data) => HomeworkTracking.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to bulk get homework tracking for homework: $e');
    }
  }
}
