import 'package:drift/drift.dart';

@DataClassName('SMSParsingPattern')
class SMSParsingPatterns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get senderIdentifier => text()();
  TextColumn get patternName => text()();
  TextColumn get messageStructure => text()();
  TextColumn get amountPattern => text()();
  TextColumn get counterpartyPattern => text()();
  TextColumn get datePattern => text().nullable()();
  TextColumn get referencePattern => text().nullable()();
  TextColumn get transactionType => text()();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  TextColumn get defaultCategoryId => text().withDefault(const Constant(''))();
  TextColumn get defaultAccountId => text().withDefault(const Constant(''))();
  IntColumn get autoSelectAccount => integer().withDefault(const Constant(0))();
  TextColumn get senderName => text().withDefault(const Constant(''))();
  TextColumn get sampleSms => text().withDefault(const Constant(''))();
  IntColumn get createdTimestamp => integer()();
  IntColumn get lastUsedTimestamp => integer().nullable()();
}
