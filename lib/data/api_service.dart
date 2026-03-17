import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/domain/entities/quiz_models.dart';
import 'package:biblesos/core/config/env_config.dart';

class ApiService {
  static const String _baseUrl = EnvConfig.baseUrl;

  Future<List<Translation>> fetchTranslations() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/translations'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Translation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load translations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching translations: $e');
    }
  }

  Future<List<Level>> fetchLevels() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/levels'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Level.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load levels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching levels: $e');
    }
  }

  Future<List<Quiz>> fetchQuizzesByLevel(int levelId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/levels/$levelId/quizzes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Quiz.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load quizzes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching quizzes: $e');
    }
  }

  Future<List<Question>> fetchQuestionsByQuiz(int quizId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/levels/quizzes/$quizId/questions'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }
}
