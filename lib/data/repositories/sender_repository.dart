import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/dao/sender_dao.dart';
import '../models/sender.dart' as models;

class SenderRepository {
  final SenderDao _senderDao;

  SenderRepository(this._senderDao);

  Future<List<models.Sender>> getAllSenders() async {
    final senders = await _senderDao.getAllSenders();
    return senders.map(_toModel).toList();
  }

  Future<List<models.Sender>> getIgnoredSenders() async {
    final senders = await _senderDao.getIgnoredSenders();
    return senders.map(_toModel).toList();
  }

  Future<models.Sender?> getSenderByName(String senderName) async {
    final sender = await _senderDao.getSenderByName(senderName);
    if (sender == null) return null;
    return _toModel(sender);
  }

  Future<bool> isSenderIgnored(String senderName) =>
      _senderDao.isSenderIgnored(senderName);

  Future<int> insertSender(models.Sender sender) async {
    final companion = SendersCompanion(
      senderName: Value(sender.senderName),
      accountId: Value(sender.accountId),
      description: Value(sender.description),
      isIgnored: Value(sender.isIgnored ? 1 : 0),
      ignoreReason: Value(sender.ignoreReason),
      ignoredAt: Value(sender.ignoredAt),
    );
    return await _senderDao.insertSender(companion);
  }

  Future<bool> updateSender(models.Sender sender) async {
    final dbSender = Sender(
      id: sender.id,
      senderName: sender.senderName,
      accountId: sender.accountId,
      description: sender.description,
      isIgnored: sender.isIgnored ? 1 : 0,
      ignoreReason: sender.ignoreReason,
      ignoredAt: sender.ignoredAt,
    );
    return await _senderDao.updateSender(dbSender);
  }

  Future<bool> markAsIgnored(String senderName, String? reason) =>
      _senderDao.markAsIgnored(senderName, reason);

  Future<bool> unmarkAsIgnored(String senderName) =>
      _senderDao.unmarkAsIgnored(senderName);

  Future<bool> deleteSender(int id) => _senderDao.deleteSender(id);

  models.Sender _toModel(Sender s) {
    return models.Sender(
      id: s.id,
      senderName: s.senderName,
      accountId: s.accountId,
      description: s.description,
      isIgnored: s.isIgnored == 1,
      ignoreReason: s.ignoreReason,
      ignoredAt: s.ignoredAt,
    );
  }
}
