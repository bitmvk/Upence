import 'package:upence/data/local/database/dao/parsing_pattern_dao.dart';
import 'package:upence/data/local/database/dao/sender_filter_dao.dart';
import 'package:upence/data/local/database/database.dart';

class RulesRepository {
  final ParsingPatternDao _parsingPatternDao;
  final SenderFilterDao _senderFilterDao;

  RulesRepository(this._parsingPatternDao, this._senderFilterDao);

  Future<List<ParsingPattern>> getAllParsingPatterns() async {
    return await _parsingPatternDao.getAllRules();
  }

  Future<List<ParsingPattern>> getAllActiveParsingPatterns() async {
    return await _parsingPatternDao.getAllActiveRules();
  }

  Future<ParsingPattern?> getParsingPattern(int id) async {
    return await _parsingPatternDao.getRule(id);
  }

  Future<int> addParsingPattern(ParsingPattern parsingPattern) async {
    return await _parsingPatternDao.insertRule(parsingPattern);
  }

  Future<bool> updateParsingPattern(ParsingPattern parsingPattern) async {
    return await _parsingPatternDao.updateRule(parsingPattern);
  }

  Future<int> deleteParsingPattern(int id) async {
    return await _parsingPatternDao.deleteRule(id);
  }

  Future<bool> deactivateParsingPattern(int id) async {
    return await _parsingPatternDao.deactivateRule(id);
  }

  Future<bool> activateParsingPattern(int id) async {
    return await _parsingPatternDao.activateRule(id);
  }

  Future<List<SenderFilter>> getAllSenderFilters() async {
    return await _senderFilterDao.getAllFilters();
  }

  Future<List<SenderFilter>> getAllActiveSenderFilters() async {
    return await _senderFilterDao.getAllActiveFilters();
  }

  Future<SenderFilter?> getSenderFilter(int id) async {
    return await _senderFilterDao.getFilter(id);
  }

  Future<int> addSenderFilter(SenderFilter senderFilter) async {
    return await _senderFilterDao.insertFilter(senderFilter);
  }

  Future<bool> updateSenderFilter(SenderFilter senderFilter) async {
    return await _senderFilterDao.updateFilter(senderFilter);
  }

  Future<int> deleteSenderFilter(int id) async {
    return await _senderFilterDao.deleteFilter(id);
  }

  Future<bool> deactivateSenderFilter(int id) async {
    return await _senderFilterDao.deactivateFilter(id);
  }

  Future<bool> activateSenderFilter(int id) async {
    return await _senderFilterDao.activateFilter(id);
  }
}
