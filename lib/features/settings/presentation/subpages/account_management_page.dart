import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/bank_account.dart';
import '../widgets/management_base_widget.dart';

class AccountManagementPage extends ConsumerWidget {
  const AccountManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseManagementPage<BankAccount>(
      title: 'Bank Accounts',
      itemsProvider: bankAccountsProvider,
      availableColors: [],
      buildLeading: (account) => const CircleAvatar(
        backgroundColor: Color(0xFF4361EE),
        child: Icon(Icons.account_balance, color: Colors.white),
      ),
      buildTitle: (account) => Text(account.accountName),
      buildSubtitle: (account) => Text(
        '•• ${account.accountNumber.substring(account.accountNumber.length - 4)}',
      ),
      getName: (account) => account.accountName,
      buildDialogFields:
          (
            nameController,
            extraControllers,
            setState,
            selectedColor,
            existingAccount,
          ) {
            if (!extraControllers.containsKey('accountNumber')) {
              extraControllers['accountNumber'] = TextEditingController(
                text: existingAccount?.accountNumber ?? '',
              );
            }
            if (!extraControllers.containsKey('description')) {
              extraControllers['description'] = TextEditingController(
                text: existingAccount?.description ?? '',
              );
            }

            return [
              buildTextField(
                controller: extraControllers['accountNumber']!,
                labelText: 'Account Number',
                keyboardType: TextInputType.number,
              ),
              buildTextField(
                controller: extraControllers['description']!,
                labelText: 'Description',
              ),
            ];
          },
      onSave: (name, extraFields, color, existingAccount) async {
        final repo = ref.read(bankAccountRepositoryProvider);

        if (existingAccount == null) {
          await repo.insertAccount(
            BankAccount(
              id: 0,
              accountName: name,
              accountNumber: extraFields['accountNumber'] ?? '',
              description: extraFields['description'] ?? '',
            ),
          );
        } else {
          await repo.updateAccount(
            existingAccount.copyWith(
              accountName: name,
              accountNumber:
                  extraFields['accountNumber'] ?? existingAccount.accountNumber,
              description:
                  extraFields['description'] ?? existingAccount.description,
            ),
          );
        }

        ref.invalidate(bankAccountsProvider);
      },
      onDelete: (id) async {
        final repo = ref.read(bankAccountRepositoryProvider);
        await repo.deleteAccount(id);
        ref.invalidate(bankAccountsProvider);
      },
    );
  }
}
