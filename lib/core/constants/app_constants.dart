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

  // About
  static const String appDescription = '''
A simple expense tracking app that automatically parses SMS messages to track your transactions.

Features:
• Automatic SMS parsing and transaction tracking
• Categorize expenses with custom categories
• Visual analytics and reports
• Bank account management
• Ignore unwanted senders
  ''';

  static const String githubUrl = 'https://github.com/bitmvk/Upence';
  static const String licenseName = 'MIT License';
  static const String licenseUrl = 'https://opensource.org/licenses/MIT';

  // TODO: Replace with actual support email before release
  static const String supportEmail = 'support@upence.com';

  static const String bugReportUrl =
      'https://github.com/bitmvk/Upence/issues/new';
  static const String feedbackUrl =
      'https://github.com/bitmvk/Upence/issues/new?labels=feedback';
}
