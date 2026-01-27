import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/bank_accounts.dart';

part 'bank_account_dao.g.dart';

@DriftAccessor(tables: [BankAccounts])
class BankAccountDao extends DatabaseAccessor<AppDatabase>
    with _$BankAccountDaoMixin {
  BankAccountDao(super.db);

  Future<List<BankAccount>> getAllAccounts() => select(bankAccounts).get();

  Future<BankAccount?> getAccountById(int id) =>
      (select(bankAccounts)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<int> insertAccount(BankAccountsCompanion account) =>
      into(bankAccounts).insert(account);

  Future<bool> updateAccount(BankAccount account) =>
      update(bankAccounts).replace(account);

  Future<bool> deleteAccount(int id) async {
    final count = await (delete(
      bankAccounts,
    )..where((a) => a.id.equals(id))).go();
    return count > 0;
  }
}
