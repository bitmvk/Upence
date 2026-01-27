import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/dao/pattern_dao.dart';
import '../models/sms_parsing_pattern.dart' as models;
import '../models/transaction.dart' as enums;

class PatternRepository {
  final PatternDao _patternDao;

  PatternRepository(this._patternDao);

  Future<List<models.SMSParsingPattern>> getAllPatterns() async {
    final patterns = await _patternDao.getAllPatterns();
    return patterns.map(_toModel).toList();
  }

  Future<List<models.SMSParsingPattern>> getActivePatterns() async {
    final patterns = await _patternDao.getActivePatterns();
    return patterns.map(_toModel).toList();
  }

  Future<List<models.SMSParsingPattern>> getPatternsBySender(
    String sender,
  ) async {
    final patterns = await _patternDao.getPatternsBySender(sender);
    return patterns.map(_toModel).toList();
  }

  Future<models.SMSParsingPattern?> getPatternById(int id) async {
    final pattern = await _patternDao.getPatternById(id);
    if (pattern == null) return null;
    return _toModel(pattern);
  }

  Future<int> insertPattern(models.SMSParsingPattern pattern) async {
    final companion = SMSParsingPatternsCompanion(
      senderIdentifier: Value(pattern.senderIdentifier),
      patternName: Value(pattern.patternName),
      messageStructure: Value(pattern.messageStructure),
      amountPattern: Value(pattern.amountPattern),
      counterpartyPattern: Value(pattern.counterpartyPattern),
      datePattern: Value(pattern.datePattern),
      referencePattern: Value(pattern.referencePattern),
      transactionType: Value(pattern.transactionType.value),
      isActive: Value(pattern.isActive ? 1 : 0),
      defaultCategoryId: Value(pattern.defaultCategoryId),
      defaultAccountId: Value(pattern.defaultAccountId),
      autoSelectAccount: Value(pattern.autoSelectAccount ? 1 : 0),
      senderName: Value(pattern.senderName),
      sampleSms: Value(pattern.sampleSms),
      createdTimestamp: Value(pattern.createdTimestamp),
      lastUsedTimestamp: Value(pattern.lastUsedTimestamp),
    );
    return await _patternDao.insertPattern(companion);
  }

  Future<bool> updatePattern(models.SMSParsingPattern pattern) async {
    final dbPattern = SMSParsingPattern(
      id: pattern.id,
      senderIdentifier: pattern.senderIdentifier,
      patternName: pattern.patternName,
      messageStructure: pattern.messageStructure,
      amountPattern: pattern.amountPattern,
      counterpartyPattern: pattern.counterpartyPattern,
      datePattern: pattern.datePattern,
      referencePattern: pattern.referencePattern,
      transactionType: pattern.transactionType.value,
      isActive: pattern.isActive ? 1 : 0,
      defaultCategoryId: pattern.defaultCategoryId,
      defaultAccountId: pattern.defaultAccountId,
      autoSelectAccount: pattern.autoSelectAccount ? 1 : 0,
      senderName: pattern.senderName,
      sampleSms: pattern.sampleSms,
      createdTimestamp: pattern.createdTimestamp,
      lastUsedTimestamp: pattern.lastUsedTimestamp,
    );
    return await _patternDao.updatePattern(dbPattern);
  }

  Future<bool> updatePatternLastUsed(int id) =>
      _patternDao.updatePatternLastUsed(id);

  Future<bool> togglePatternActive(int id, bool isActive) =>
      _patternDao.togglePatternActive(id, isActive);

  Future<bool> deletePattern(int id) => _patternDao.deletePattern(id);

  models.SMSParsingPattern _toModel(SMSParsingPattern p) {
    return models.SMSParsingPattern(
      id: p.id,
      senderIdentifier: p.senderIdentifier,
      patternName: p.patternName,
      messageStructure: p.messageStructure,
      amountPattern: p.amountPattern,
      counterpartyPattern: p.counterpartyPattern,
      datePattern: p.datePattern,
      referencePattern: p.referencePattern,
      transactionType: enums.TransactionType.values.firstWhere(
        (e) => e.value == p.transactionType,
        orElse: () => enums.TransactionType.debit,
      ),
      isActive: p.isActive == 1,
      defaultCategoryId: p.defaultCategoryId,
      defaultAccountId: p.defaultAccountId,
      autoSelectAccount: p.autoSelectAccount == 1,
      senderName: p.senderName,
      sampleSms: p.sampleSms,
      createdTimestamp: p.createdTimestamp,
      lastUsedTimestamp: p.lastUsedTimestamp,
    );
  }
}
