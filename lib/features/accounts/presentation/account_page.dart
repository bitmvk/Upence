import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/page_wrapper.dart';
import 'widgets/account_card.dart';
import 'widgets/account_icon_selector.dart';
import '../../../data/models/bank_account.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(bankAccountsProvider);

    return PageWrapper(
      title: const Text('Bank Accounts'),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No accounts yet',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddEditAccountSheet(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Account'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return AccountCard(
                account: account,
                onMenuTap: () => _showAccountMenu(context, ref, account),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditAccountSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }

  void _showAddEditAccountSheet(
    BuildContext context,
    WidgetRef ref, {
    BankAccount? existingAccount,
  }) {
    final accountNameController = TextEditingController(
      text: existingAccount?.accountName ?? '',
    );
    final accountNumberController = TextEditingController(
      text: existingAccount?.accountNumber ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingAccount?.description ?? '',
    );
    String selectedIcon = existingAccount?.icon ?? 'account_balance_wallet';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingAccount == null
                      ? 'Add Bank Account'
                      : 'Edit Bank Account',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: accountNameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Account Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Account Number (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                AccountIconSelector(
                  selectedIcon: selectedIcon,
                  onIconSelected: (icon) =>
                      setSheetState(() => selectedIcon = icon),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (accountNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account name is required'),
                        ),
                      );
                      return;
                    }

                    final repo = ref.read(bankAccountRepositoryProvider);

                    if (existingAccount == null) {
                      await repo.insertAccount(
                        BankAccount(
                          id: 0,
                          accountName: accountNameController.text.trim(),
                          accountNumber: accountNumberController.text.trim(),
                          description: descriptionController.text.trim(),
                          icon: selectedIcon,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account added')),
                      );
                    } else {
                      await repo.updateAccount(
                        existingAccount.copyWith(
                          accountName: accountNameController.text.trim(),
                          accountNumber: accountNumberController.text.trim(),
                          description: descriptionController.text.trim(),
                          icon: selectedIcon,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account updated')),
                      );
                    }

                    ref.invalidate(bankAccountsProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: Text(
                    existingAccount == null ? 'Add Account' : 'Save Changes',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context, WidgetRef ref, dynamic account) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Account'),
              onTap: () {
                Navigator.pop(context);
                _showAddEditAccountSheet(
                  context,
                  ref,
                  existingAccount: account,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, ref, account);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete ${account.accountName}? This will not delete transactions associated with this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final repo = ref.read(bankAccountRepositoryProvider);
              await repo.deleteAccount(account.id);
              ref.invalidate(bankAccountsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
