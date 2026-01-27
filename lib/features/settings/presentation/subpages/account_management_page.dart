import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/bank_account.dart';

class AccountManagementPage extends ConsumerStatefulWidget {
  const AccountManagementPage({super.key});

  @override
  ConsumerState<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends ConsumerState<AccountManagementPage> {
  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(bankAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAccountDialog(),
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text('No accounts yet'),
            );
          }

          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.account_balance, color: Colors.white),
                ),
                title: Text(account.accountName),
                subtitle: Text('•••• ${account.accountNumber.substring(
                  account.accountNumber.length - 4,
                )}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditAccountDialog(account),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: AppColors.expense,
                      onPressed: () => _showDeleteDialog(account),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showAddAccountDialog() {
    _showAccountDialog(null);
  }

  void _showEditAccountDialog(BankAccount account) {
    _showAccountDialog(account);
  }

  void _showAccountDialog(BankAccount? account) {
    final nameController = TextEditingController(text: account?.accountName ?? '');
    final numberController = TextEditingController(text: account?.accountNumber ?? '');
    final descriptionController = TextEditingController(text: account?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account == null ? 'Add Account' : 'Edit Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Account Number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || numberController.text.isEmpty) return;

              final repo = ref.read(bankAccountRepositoryProvider);
              if (account == null) {
                await repo.insertAccount(
                  BankAccount(
                    id: 0,
                    accountName: nameController.text,
                    accountNumber: numberController.text,
                    description: descriptionController.text,
                  ),
                );
              } else {
                await repo.updateAccount(
                  account.copyWith(
                    accountName: nameController.text,
                    accountNumber: numberController.text,
                    description: descriptionController.text,
                  ),
                );
              }
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(bankAccountsProvider);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BankAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.accountName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(bankAccountRepositoryProvider);
              await repo.deleteAccount(account.id);
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(bankAccountsProvider);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
