import 'dart:developer';

class AppLogger {
  static void error(
    String message, {
    required Object error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    final prefix = tag != null ? '[$tag] ' : '';
    log('$prefix$message', error: error, stackTrace: stackTrace);
  }

  static void info(String message, {String? tag}) {
    final prefix = tag != null ? '[$tag] ' : '';
    log('$prefix$message');
  }

  static void debug(String message, {String? tag}) {
    final prefix = tag != null ? '[$tag] ' : '';
    log('$prefix[DEBUG] $message');
  }
}
