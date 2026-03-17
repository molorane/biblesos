import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:biblesos/domain/entities/bible_models.dart';
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
}
