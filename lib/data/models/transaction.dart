enum TransactionType {
  credit('CREDIT', 'Credit'),
  debit('DEBIT', 'Debit');

  final String value;
  final String displayName;

  const TransactionType(this.value, this.displayName);

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TransactionType.debit,
    );
  }
}
