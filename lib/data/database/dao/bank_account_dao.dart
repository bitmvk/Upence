import 'package:drift/drift.dart';
import 'package:upence/data/database/database.dart';
import 'package:upence/data/database/tables/bank_accounts.dart';

part 'bank_account_dao.g.dart';

@DriftAccessor(tables: [BankAccounts])
class BankAccountDao extends DatabaseAccessor<AppDatabase>
    with _$BankAccountDaoMixin {
  BankAccountDao(AppDatabase db) : super(db);

  Future<List<BankAccount>> getAllAccounts({int? limit, int? offset}) async {
    final query = select(bankAccounts);
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<BankAccount?> getAccountById(int id) async {
    return (select(
      bankAccounts,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertAccount(BankAccount account) {
    return into(bankAccounts).insert(account);
  }

  Future<bool> updateAccount(BankAccount account) {
    return update(bankAccounts).replace(account);
  }

  Future<int> deleteAccount(int id) {
    return (delete(bankAccounts)..where((tbl) => tbl.id.equals(id))).go();
  }
}
