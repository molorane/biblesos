import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/data/topic_database_service.dart';

abstract class TopicRepository {
  Future<List<Topic>> getTopics();
  Future<List<TopicContent>> getTopicContent(int topicId);
  Future<List<Topic>> searchTopics(String query);
}

class TopicRepositoryImpl implements TopicRepository {
  final TopicDatabaseService _dbService = TopicDatabaseService();

  @override
  Future<List<Topic>> getTopics() async {
    return await _dbService.getTopics();
  }

  @override
  Future<List<TopicContent>> getTopicContent(int topicId) async {
    return await _dbService.getTopicContent(topicId);
  }

  @override
  Future<List<Topic>> searchTopics(String query) async {
    return await _dbService.searchTopics(query);
  }
}
