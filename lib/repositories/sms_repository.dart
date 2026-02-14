import 'package:drift/drift.dart';
import 'package:upence/data/local/database/dao/sms_dao.dart';
import 'package:upence/data/local/database/database.dart';

class SmsRepository {
  final SmsDao _smsDao;

  SmsRepository(this._smsDao);

  Future<List<Sms>> getAllSms({int? limit, int? offset}) async {
    return await _smsDao.getAllSms(limit: limit, offset: offset);
  }

  Future<Sms?> getSms(int id) async {
    return await _smsDao.getSms(id);
  }

  Future<List<Sms>> getUnprocessedSms({int? limit}) async {
    return await _smsDao.filterSms(
      statuses: ['pending'],
      isDeleted: false,
      limit: limit,
    );
  }

  Future<List<Sms>> getTransactionSms({int? limit, int? offset}) async {
    return await _smsDao.filterSms(
      isTransaction: true,
      isDeleted: false,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> addSms(Sms sms) async {
    return await _smsDao.insertSms(sms);
  }

  Future<int> deleteSms(int id) async {
    return await _smsDao.deleteSms(id);
  }

  Future<bool> softDeleteSms(int id) async {
    return await _smsDao.markAsDeleted(id);
  }

  Future<bool> markAsProcessed(int id) async {
    final rowsAffected = await _updateSmsStatus(
      id,
      status: 'processed',
      processedAt: DateTime.now(),
    );
    return rowsAffected > 0;
  }

  Future<bool> markAsIgnored(int id) async {
    final rowsAffected = await _updateSmsStatus(
      id,
      status: 'ignored',
      processedAt: DateTime.now(),
    );
    return rowsAffected > 0;
  }

  Future<int> _updateSmsStatus(
    int id, {
    required String status,
    DateTime? processedAt,
  }) async {
    final db = _smsDao.db;
    return (db.update(db.smsMessages)..where((tbl) => tbl.id.equals(id))).write(
      SmsMessagesCompanion(
        status: Value(status),
        processedAt: Value(processedAt),
      ),
    );
  }

  Future<int> getUnprocessedCount() async {
    return await _smsDao.countSms(statuses: ['pending'], isDeleted: false);
  }
}
