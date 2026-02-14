import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upence/core/ui/category_icons.dart';
import 'package:upence/core/ui/icon_mapper.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/views/setup/setup_view_model.dart';

class AccountsSetupPage extends ConsumerWidget {
  const AccountsSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(
      setupViewModelProvider.select((state) => state.accounts),
    );
    final viewModel = ref.read(setupViewModelProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Bank Accounts',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Add your bank accounts for transaction tracking.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: accounts.isEmpty
              ? Center(
                  child: Text(
                    'No accounts added yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return _AccountCard(
                      account: account,
                      onEdit: () =>
                          _showEditDialog(context, ref, account, index),
                      onDelete: () => viewModel.removeAccount(index),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Account'),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AccountDialog(
        onSave: (account) {
          ref.read(setupViewModelProvider.notifier).addAccount(account);
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    BankAccount account,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => _AccountDialog(
        account: account,
        onSave: (updatedAccount) {
          ref
              .read(setupViewModelProvider.notifier)
              .updateAccount(updatedAccount, index);
        },
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final BankAccount account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AccountCard({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            iconMap[account.icon],
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(account.name),
        subtitle: account.number != null
            ? Text('Account: ${account.number}')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _AccountDialog extends StatefulWidget {
  final BankAccount? account;
  final Function(BankAccount) onSave;

  const _AccountDialog({this.account, required this.onSave});

  @override
  State<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<_AccountDialog> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _descriptionController;
  String _icon = "account_balance";
  final financeIcons = iconMap.entries
      .where((e) => FinanceIcons.all.contains(e.key))
      .toList();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _numberController = TextEditingController(
      text: widget.account?.number ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.account?.description ?? '',
    );
    if (widget.account != null) {
      _icon = widget.account!.icon;
    }

    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.account == null ? 'Add Account' : 'Edit Account'),
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    labelText: 'Account Number (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _icon,
                  items: financeIcons.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key, // Use the key as the value
                      child: Icon(entry.value), // Use the IconData for display
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _icon = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isNotEmpty
              ? () {
                  widget.onSave(
                    BankAccount(
                      id: widget.account?.id ?? 0,
                      name: _nameController.text,
                      number: _numberController.text.isEmpty
                          ? null
                          : _numberController.text,
                      description: _descriptionController.text.isEmpty
                          ? null
                          : _descriptionController.text,
                      icon: _icon,
                    ),
                  );
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
