class AppConstants {
  // App Info
  static const String appName = 'Upence';
  static const String appVersion = '1.0.0';

  // SMS
  static const int smsCacheSize = 50;
  static const int notificationTimeoutMs = 60000;

  // Pattern Matching
  static const double patternMatchThreshold = 0.5;

  // Permissions
  static const String permissionSmsRead = 'android.permission.READ_SMS';
  static const String permissionSmsReceive = 'android.permission.RECEIVE_SMS';
  static const String permissionNotifications =
      'android.permission.POST_NOTIFICATIONS';
  static const String permissionForegroundService =
      'android.permission.FOREGROUND_SERVICE';

  // Notification Channel
  static const String smsChannelId = 'upence_sms_channel';
  static const String smsChannelName = 'Transaction Alerts';
  static const String smsChannelDesc = 'Notifications for SMS transactions';

  // Platform Channels
  static const String smsReceiverChannel = 'com.upence/sms_receiver';

  // Transaction Types
  static const String transactionTypeCredit = 'CREDIT';
  static const String transactionTypeDebit = 'DEBIT';

  // Navigation
  static const String routeHome = '/';
  static const String routeSmsProcessing = '/sms_processing';
  static const String routeUnprocessedSms = '/unprocessed_sms';
  static const String routeSettings = '/settings';
  static const String routeAnalytics = '/analytics';
  static const String routeAccounts = '/accounts';
  static const String routeCategories = '/settings/categories';
  static const String routeTags = '/settings/tags';
  static const String routePatterns = '/settings/patterns';
  static const String routeIgnoredSenders = '/settings/ignored_senders';
}
