enum TransactionType { credit, debit }

enum SmsStatus { pending, processed, ignored }

extension TransactionTypeX on TransactionType {
  String get value => switch (this) {
    TransactionType.credit => 'credit',
    TransactionType.debit => 'debit',
  };

  static TransactionType? fromString(String value) => switch (value) {
    'credit' => TransactionType.credit,
    'debit' => TransactionType.debit,
    _ => null,
  };
}

extension SmsStatusX on SmsStatus {
  String get value => switch (this) {
    SmsStatus.pending => 'pending',
    SmsStatus.processed => 'processed',
    SmsStatus.ignored => 'ignored',
  };

  static SmsStatus? fromString(String value) => switch (value) {
    'pending' => SmsStatus.pending,
    'processed' => SmsStatus.processed,
    'ignored' => SmsStatus.ignored,
    _ => null,
  };
}

class AppDateTimeRange {
  final DateTime start;
  final DateTime end;

  const AppDateTimeRange({required this.start, required this.end});
}

class DateFormatter {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static List<String> get months => _months;

  static String formatShortDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day} ${_months[dateTime.month - 1]}';
    }
  }

  static String formatShortDateWithTime(DateTime dateTime) {
    final dateStr = formatShortDate(dateTime);
    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr, $timeStr';
  }

  static String formatFullDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static String formatMonthYear(DateTime date) {
    return _months[date.month - 1];
  }

  static String formatMonthName(int month) {
    return _months[month - 1];
  }

  static String formatMonthAndYear(DateTime date) {
    return '${_months[date.month - 1]} ${date.year}';
  }

  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
}

class CurrencyFormatter {
  static const String symbol = '₹';

  static String format(
    int amountCents, {
    bool showSign = false,
    bool? isCredit,
  }) {
    final amount = amountCents / 100;
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    final prefix = showSign && isCredit != null
        ? (isCredit ? '+' : '-')
        : (isNegative ? '-' : '');

    final formatted = _formatAmount(absAmount);
    return '$prefix$formatted';
  }

  static String formatAbs(int amountCents) {
    final absAmount = (amountCents / 100).abs();
    return _formatAmount(absAmount);
  }

  static String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
  }
}
