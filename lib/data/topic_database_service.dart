import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:biblesos/domain/entities/bible_models.dart';

class TopicDatabaseService {
  static final TopicDatabaseService _instance = TopicDatabaseService._internal();
  static Database? _database;

  factory TopicDatabaseService() => _instance;

  TopicDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = p.join(await getDatabasesPath(), 'app.db');
    bool exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(p.dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(p.join('assets', 'db', 'app.db'));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path, version: 1);
  }

  Future<List<Topic>> getTopics() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('k_word', orderBy: 'text ASC');
    return maps.map((m) => Topic.fromMap(m)).toList();
  }

  Future<List<TopicContent>> getTopicContent(int topicId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'k_data',
      where: 'kword_id = ?',
      whereArgs: [topicId],
    );
    return maps.map((m) => TopicContent.fromMap(m)).toList();
  }

  Future<List<Topic>> searchTopics(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'k_word',
      where: 'text LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'text ASC',
    );
    return maps.map((m) => Topic.fromMap(m)).toList();
  }
}
