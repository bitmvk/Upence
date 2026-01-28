class FinancialOverview {
  final double balance;
  final double income;
  final double expense;

  FinancialOverview({
    required this.balance,
    required this.income,
    required this.expense,
  });

  FinancialOverview copyWith({
    double? balance,
    double? income,
    double? expense,
  }) {
    return FinancialOverview(
      balance: balance ?? this.balance,
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }
}
