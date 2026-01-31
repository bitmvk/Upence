import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/dao/regex_sender_patterns_dao.dart';
import '../models/regex_sender_pattern.dart' as models;

class RegexSenderPatternsRepository {
  final RegexSenderPatternsDao _dao;

  RegexSenderPatternsRepository(this._dao);

  Future<List<models.RegexSenderPattern>> getAllPatterns() async {
    final patterns = await _dao.getAllPatterns();
    return patterns.map(_toModel).toList();
  }

  Future<List<models.RegexSenderPattern>> getActivePatterns() async {
    final patterns = await _dao.getActivePatterns();
    return patterns.map(_toModel).toList();
  }

  Future<int> insertPattern(models.RegexSenderPattern pattern) async {
    final companion = RegexSenderPatternsCompanion(
      regexPattern: Value(pattern.regexPattern),
      description: Value(pattern.description),
      priority: Value(pattern.priority),
      isActive: Value(pattern.isActive ? 1 : 0),
      createdTimestamp: Value(pattern.createdTimestamp),
    );
    return await _dao.insertPattern(companion);
  }

  Future<bool> updatePattern(models.RegexSenderPattern pattern) async {
    final dbPattern = RegexSenderPattern(
      id: pattern.id,
      regexPattern: pattern.regexPattern,
      description: pattern.description,
      priority: pattern.priority,
      isActive: pattern.isActive ? 1 : 0,
      createdTimestamp: pattern.createdTimestamp,
    );
    return await _dao.updatePattern(dbPattern);
  }

  Future<bool> deletePattern(int id) => _dao.deletePattern(id);

  Future<List<String>> findMatchingPatterns(String sender) async {
    final patterns = await getActivePatterns();
    final matching = <String>[];
    for (final pattern in patterns) {
      try {
        final regex = RegExp(pattern.regexPattern);
        if (regex.hasMatch(sender)) {
          matching.add(pattern.regexPattern);
        }
      } catch (e) {
        continue;
      }
    }
    return matching;
  }

  models.RegexSenderPattern _toModel(RegexSenderPattern p) {
    return models.RegexSenderPattern(
      id: p.id,
      regexPattern: p.regexPattern,
      description: p.description,
      priority: p.priority,
      isActive: p.isActive == 1,
      createdTimestamp: p.createdTimestamp,
    );
  }
}
