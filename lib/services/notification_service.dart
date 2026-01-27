import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _notificationController = StreamController<int>.broadcast();
  Stream<int> get notificationStream => _notificationController.stream;

  static const String _channelId = 'transaction_alerts';
  static const String _channelName = 'Transaction Alerts';
  static const String _channelDescription =
      'Notifications for new SMS transactions';

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> showSMSNotification({
    required int smsId,
    required String sender,
    String? amount,
    required String message,
  }) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        visibility: NotificationVisibility.public,
      ),
    );

    final title = 'New SMS from $sender';
    final body = amount != null ? 'Amount: ₹$amount\n$message' : message;

    await _notificationsPlugin.show(
      smsId,
      title,
      body,
      notificationDetails,
      payload: 'sms_id:$smsId',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getActiveNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    if (response.id != null) {
      _notificationController.add(response.id!);
    }
  }

  void dispose() {
    _notificationController.close();
  }
}
