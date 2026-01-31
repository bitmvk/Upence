import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/sms.dart';
import '../features/sms/services/sms_rules_service.dart' as rules;
import '../features/sms/services/sms_parsing_service.dart';
import 'notification_service.dart';

class SMSService {
  static final SMSService _instance = SMSService._internal();
  factory SMSService() => _instance;
  SMSService._internal();

  final rules.SMSRulesService _smsRulesService = rules.SMSRulesService();

  final SmsQuery _query = SmsQuery();
  final SMSParsingService _parsingService = SMSParsingService();
  final NotificationService _notificationService = NotificationService();

  static const int _maxCacheSize = 50;

  final _smsController = StreamController<SMSMessage>.broadcast();
  Stream<SMSMessage> get smsStream => _smsController.stream;

  Future<bool> hasPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<List<SMSMessage>> querySMS({
    int limit = 50,
    int? startTimestamp,
  }) async {
    if (!await hasPermission()) {
      debugPrint('SMS permission not granted');
      return [];
    }

    final messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: limit,
      start: startTimestamp,
    );

    final bankMessages = messages
        .where((msg) => _isBankMessage(msg.sender ?? ''))
        .map((msg) => _convertToSMSMessage(msg))
        .toList();

    return bankMessages;
  }

  SMSMessage _convertToSMSMessage(SmsMessage msg) {
    int timestamp;
    if (msg.date != null) {
      timestamp = msg.date is int
          ? msg.date as int
          : DateTime.now().millisecondsSinceEpoch;
    } else {
      timestamp = DateTime.now().millisecondsSinceEpoch;
    }

    return SMSMessage(
      id: msg.id ?? DateTime.now().millisecondsSinceEpoch,
      sender: msg.sender ?? 'Unknown',
      message: msg.body ?? '',
      timestamp: timestamp,
      processed: false,
    );
  }

  bool _isBankMessage(String sender) {
    return _smsRulesService.matchesTransactionSender(sender);
  }

  Future<void> processNewSMS(SMSMessage sms) async {
    if (!_isBankMessage(sms.sender)) {
      return;
    }

    _smsController.add(sms);

    // Try to extract amount for notification
    final words = sms.message.split(' ');
    final amount = _extractAmountFromMessage(words);

    await _notificationService.showSMSNotification(
      smsId: sms.id,
      sender: sms.sender,
      amount: amount,
      message: sms.message,
    );
  }

  String? _extractAmountFromMessage(List<String> words) {
    for (final word in words) {
      final cleaned = word.replaceAll(RegExp(r'[^\d.]'), '');
      if (cleaned.isNotEmpty && cleaned.contains('.')) {
        try {
          final amount = double.parse(cleaned);
          if (amount > 0) {
            return cleaned;
          }
        } catch (_) {}
      }
    }
    return null;
  }

  Future<void> initialize() async {
    await _smsRulesService.initialize();
  }

  Future<void> syncSMS() async {
    if (!await hasPermission()) {
      debugPrint('SMS permission not granted');
      return;
    }

    final messages = await querySMS(limit: _maxCacheSize);

    for (final message in messages) {
      await processNewSMS(message);
    }
  }

  void dispose() {
    _smsController.close();
  }
}
