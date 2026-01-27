import 'transaction.dart';

class Transaction {
  final int id;
  final String counterParty;
  final double amount;
  final DateTime timestamp;
  final String categoryId;
  final String description;
  final String accountId;
  final TransactionType transactionType;
  final String referenceNumber;

  Transaction({
    this.id = 0,
    required this.counterParty,
    required this.amount,
    required this.timestamp,
    required this.categoryId,
    this.description = '',
    required this.accountId,
    required this.transactionType,
    this.referenceNumber = '',
  });

  Transaction copyWith({
    int? id,
    String? counterParty,
    double? amount,
    DateTime? timestamp,
    String? categoryId,
    String? description,
    String? accountId,
    TransactionType? transactionType,
    String? referenceNumber,
  }) {
    return Transaction(
      id: id ?? this.id,
      counterParty: counterParty ?? this.counterParty,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      accountId: accountId ?? this.accountId,
      transactionType: transactionType ?? this.transactionType,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }
}
