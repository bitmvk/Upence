import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/dao/sms_dao.dart';
import '../models/sms.dart' as models;

class SMSRepository {
  final SmsDao _smsDao;

  SMSRepository(this._smsDao);

  Future<List<models.SMSMessage>> getAllSMS() async {
    final smsList = await _smsDao.getAllSMS();
    return smsList.map(_toModel).toList();
  }

  Future<List<models.SMSMessage>> getUnprocessedSMS() async {
    final smsList = await _smsDao.getUnprocessedSMS();
    return smsList.map(_toModel).toList();
  }

  Future<models.SMSMessage?> getSmsById(int id) async {
    final sms = await _smsDao.getSmsById(id);
    if (sms == null) return null;
    return _toModel(sms);
  }

  Future<List<models.SMSMessage>> getSMSBySender(String sender) async {
    final smsList = await _smsDao.getSMSBySender(sender);
    return smsList.map(_toModel).toList();
  }

  Future<List<models.SMSMessage>> getRecentSMS(int limit) async {
    final smsList = await _smsDao.getRecentSMS(limit);
    return smsList.map(_toModel).toList();
  }

  Future<int> getUnprocessedCount() => _smsDao.getUnprocessedCount();

  Future<int> insertSMS(models.SMSMessage sms) async {
    final companion = SmsTableCompanion(
      sender: Value(sms.sender),
      message: Value(sms.message),
      timestamp: Value(sms.timestamp),
      processed: const Value(0),
    );
    return await _smsDao.insertSMS(companion);
  }

  Future<bool> updateSMS(models.SMSMessage sms) async {
    final dbSms = Sms(
      id: sms.id,
      sender: sms.sender,
      message: sms.message,
      timestamp: sms.timestamp,
      processed: sms.processed ? 1 : 0,
    );
    return await _smsDao.updateSMS(dbSms);
  }

  Future<bool> markAsProcessed(int id) => _smsDao.markAsProcessed(id);

  Future<bool> deleteSMS(int id) => _smsDao.deleteSMS(id);

  Future<int> deleteAllProcessedSMS() => _smsDao.deleteAllProcessedSMS();

  Future<void> maintainCacheLimit(int limit) =>
      _smsDao.maintainCacheLimit(limit);

  models.SMSMessage _toModel(Sms s) {
    return models.SMSMessage(
      id: s.id,
      sender: s.sender,
      message: s.message,
      timestamp: s.timestamp,
      processed: s.processed == 1,
    );
  }
}
