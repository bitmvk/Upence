import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/dao/sender_ignore_rules_dao.dart';
import '../models/sender_ignore_rule.dart' as models;

class SenderIgnoreRulesRepository {
  final SenderIgnoreRulesDao _dao;

  SenderIgnoreRulesRepository(this._dao);

  Future<List<models.SenderIgnoreRule>> getAllRules() async {
    final rules = await _dao.getAllRules();
    return rules.map(_toModel).toList();
  }

  Future<List<models.SenderIgnoreRule>> getActiveRules() async {
    final rules = await _dao.getActiveRules();
    return rules.map(_toModel).toList();
  }

  Future<List<models.SenderIgnoreRule>> getBundledRules() async {
    final rules = await _dao.getBundledRules();
    return rules.map(_toModel).toList();
  }

  Future<List<models.SenderIgnoreRule>> getCustomRules() async {
    final rules = await _dao.getCustomRules();
    return rules.map(_toModel).toList();
  }

  Future<int> insertRule(models.SenderIgnoreRule rule) async {
    final companion = SenderIgnoreRulesCompanion(
      ruleName: Value(rule.ruleName),
      regexPattern: Value(rule.regexPattern),
      description: Value(rule.description),
      isActive: Value(rule.isActive ? 1 : 0),
      isBundled: Value(rule.isBundled ? 1 : 0),
      createdTimestamp: Value(rule.createdTimestamp),
    );
    return await _dao.insertRule(companion);
  }

  Future<bool> updateRule(models.SenderIgnoreRule rule) async {
    final dbRule = SenderIgnoreRule(
      id: rule.id,
      ruleName: rule.ruleName,
      regexPattern: rule.regexPattern,
      description: rule.description,
      isActive: rule.isActive ? 1 : 0,
      isBundled: rule.isBundled ? 1 : 0,
      createdTimestamp: rule.createdTimestamp,
    );
    return await _dao.updateRule(dbRule);
  }

  Future<bool> toggleRuleActive(int id, bool isActive) =>
      _dao.toggleRuleActive(id, isActive);

  Future<bool> deleteRule(int id) => _dao.deleteRule(id);

  Future<bool> matchesIgnoredSenders(String sender) async {
    final activeRules = await getActiveRules();
    for (final rule in activeRules) {
      try {
        final regex = RegExp(rule.regexPattern);
        if (regex.hasMatch(sender)) {
          return true;
        }
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  models.SenderIgnoreRule _toModel(SenderIgnoreRule r) {
    return models.SenderIgnoreRule(
      id: r.id,
      ruleName: r.ruleName,
      regexPattern: r.regexPattern,
      description: r.description,
      isActive: r.isActive == 1,
      isBundled: r.isBundled == 1,
      createdTimestamp: r.createdTimestamp,
    );
  }
}
