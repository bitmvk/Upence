import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:upence/features/sms/services/sms_parsing_service.dart';
import 'package:upence/services/notification_service.dart';

class BackgroundSMSService {
  static final BackgroundSMSService _instance = BackgroundSMSService._internal();
  factory BackgroundSMSService() => _instance;
  BackgroundSMSService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        autoStartOnBoot: true,
        notificationChannelId: 'upence_background_service',
        initialNotificationTitle: 'Upence SMS Service',
        initialNotificationContent: 'Monitoring SMS messages...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  Future<void> start() async {
    await _service.startService();
  }

  Future<void> stop() async {
    _service.invoke('stop');
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    final parsingService = SMSParsingService();
    final notificationService = NotificationService();
    await notificationService.initialize();

    service.on('stop').listen((event) {
      service.stopSelf();
    });

    service.on('processSMS').listen((event) async {
      final sender = event?['sender'] as String?;
      final message = event?['message'] as String?;
      final timestamp = event?['timestamp'] as int?;

      if (sender != null && message != null && timestamp != null) {
        await _processSMSInBackground(
          sender,
          message,
          timestamp,
          parsingService,
          notificationService,
        );
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    return true;
  }

  static Future<void> _processSMSInBackground(
    String sender,
    String message,
    int timestamp,
    SMSParsingService parsingService,
    NotificationService notificationService,
  ) async {
    try {
      // Check if this is a bank message
      if (!parsingService.isBankMessage(sender)) {
        return;
      }

      // Extract amount for notification
      final words = message.split(' ');
      final amount = _extractAmountFromMessage(words);

      // Show notification
      await notificationService.showSMSNotification(
        smsId: timestamp,
        sender: sender,
        amount: amount,
        message: message,
      );

      // Store SMS in database (would need repository access here)
      // This is a simplified version - in production, you'd need proper DI
    } catch (e) {
      debugPrint('Error processing SMS in background: $e');
    }
  }

  static String? _extractAmountFromMessage(List<String> words) {
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

  void processSMS({
    required String sender,
    required String message,
    required int timestamp,
  }) {
    _service.invoke('processSMS', {
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
    });
  }
}
