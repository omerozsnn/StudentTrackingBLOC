import '../../models/homework_model.dart';
import '../../api.dart/homeworkControlApi.dart';

class HomeworkRepository {
  final ApiService _apiService;

  HomeworkRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Get all homeworks
  Future<List<Homework>> getAllHomeworks() async {
    try {
      final homeworksData = await _apiService.getAllHomeworks();
      return homeworksData.map((data) => Homework.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load homeworks: $e');
    }
  }

  // Get homework by ID
  Future<Homework> getHomeworkById(int id) async {
    try {
      final homeworkData = await _apiService.getHomeworkById(id);
      return Homework.fromJson(homeworkData);
    } catch (e) {
      throw Exception('Failed to load homework: $e');
    }
  }

  // Add a new homework
  Future<void> addHomework(Homework homework) async {
    try {
      await _apiService.addHomework(homework.toJson());
    } catch (e) {
      throw Exception('Failed to add homework: $e');
    }
  }

  // Update an existing homework
  Future<void> updateHomework(Homework homework) async {
    if (homework.id == null) {
      throw Exception('Cannot update homework without ID');
    }

    try {
      await _apiService.updateHomework(homework.id!, homework.toJson());
    } catch (e) {
      throw Exception('Failed to update homework: $e');
    }
  }

  // Delete a homework
  Future<void> deleteHomework(int id) async {
    try {
      await _apiService.deleteHomework(id);
    } catch (e) {
      throw Exception('Failed to delete homework: $e');
    }
  }
}
