import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const String defaultSymbol = '₹';
  static const String defaultCode = 'INR';

  static String format(double amount, {String? symbol}) {
    final currencySymbol = symbol ?? defaultSymbol;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: currencySymbol,
      name: defaultCode,
    );
    return formatter.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }
}
