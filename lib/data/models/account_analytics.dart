class AccountAnalytics {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;
  final double avgMonthlyIncome;
  final double avgMonthlyExpense;
  final DateTime? lastTransactionDate;

  AccountAnalytics({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
    required this.avgMonthlyIncome,
    required this.avgMonthlyExpense,
    this.lastTransactionDate,
  });

  AccountAnalytics copyWith({
    double? balance,
    double? totalIncome,
    double? totalExpense,
    int? transactionCount,
    double? avgMonthlyIncome,
    double? avgMonthlyExpense,
    DateTime? lastTransactionDate,
  }) {
    return AccountAnalytics(
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      transactionCount: transactionCount ?? this.transactionCount,
      avgMonthlyIncome: avgMonthlyIncome ?? this.avgMonthlyIncome,
      avgMonthlyExpense: avgMonthlyExpense ?? this.avgMonthlyExpense,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
    );
  }
}
