import 'package:upence/data/local/database/database.dart';

export 'package:upence/core/utils/formatters.dart' show DateTimeRange;

class CompositeTransaction {
  final Transaction transaction;
  final BankAccount? account;
  final Category? category;
  final Sms? sms;
  final List<Tag> tags;

  const CompositeTransaction({
    required this.transaction,
    this.account,
    this.category,
    this.sms,
    required this.tags,
  });
}
