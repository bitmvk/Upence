import 'transaction.dart';

class SMSParsingPattern {
  final int id;
  final String senderIdentifier;
  final String patternName;
  final String messageStructure;
  final String amountPattern;
  final String counterpartyPattern;
  final String? datePattern;
  final String? referencePattern;
  final TransactionType transactionType;
  final bool isActive;
  final String defaultCategoryId;
  final String defaultAccountId;
  final bool autoSelectAccount;
  final String senderName;
  final String sampleSms;
  final int createdTimestamp;
  final int? lastUsedTimestamp;

  SMSParsingPattern({
    this.id = 0,
    required this.senderIdentifier,
    required this.patternName,
    required this.messageStructure,
    required this.amountPattern,
    required this.counterpartyPattern,
    this.datePattern,
    this.referencePattern,
    required this.transactionType,
    this.isActive = true,
    this.defaultCategoryId = '',
    this.defaultAccountId = '',
    this.autoSelectAccount = false,
    this.senderName = '',
    this.sampleSms = '',
    required this.createdTimestamp,
    this.lastUsedTimestamp,
  });

  SMSParsingPattern copyWith({
    int? id,
    String? senderIdentifier,
    String? patternName,
    String? messageStructure,
    String? amountPattern,
    String? counterpartyPattern,
    String? datePattern,
    String? referencePattern,
    TransactionType? transactionType,
    bool? isActive,
    String? defaultCategoryId,
    String? defaultAccountId,
    bool? autoSelectAccount,
    String? senderName,
    String? sampleSms,
    int? createdTimestamp,
    int? lastUsedTimestamp,
  }) {
    return SMSParsingPattern(
      id: id ?? this.id,
      senderIdentifier: senderIdentifier ?? this.senderIdentifier,
      patternName: patternName ?? this.patternName,
      messageStructure: messageStructure ?? this.messageStructure,
      amountPattern: amountPattern ?? this.amountPattern,
      counterpartyPattern: counterpartyPattern ?? this.counterpartyPattern,
      datePattern: datePattern ?? this.datePattern,
      referencePattern: referencePattern ?? this.referencePattern,
      transactionType: transactionType ?? this.transactionType,
      isActive: isActive ?? this.isActive,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      autoSelectAccount: autoSelectAccount ?? this.autoSelectAccount,
      senderName: senderName ?? this.senderName,
      sampleSms: sampleSms ?? this.sampleSms,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      lastUsedTimestamp: lastUsedTimestamp ?? this.lastUsedTimestamp,
    );
  }
}
