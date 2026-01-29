import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/transaction.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/bank_account.dart';

class EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;
  final AsyncValue<List<dynamic>> categoriesAsync;
  final AsyncValue<List<dynamic>> accountsAsync;
  final AsyncValue<List<dynamic>> tagsAsync;
  final Future<void> Function(Transaction) onSave;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
    required this.categoriesAsync,
    required this.accountsAsync,
    required this.tagsAsync,
    required this.onSave,
  });

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  late TextEditingController _counterPartyController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _referenceController;
  late TransactionType _transactionType;
  String? _categoryId;
  String? _accountId;

  @override
  void initState() {
    super.initState();
    _counterPartyController =
        TextEditingController(text: widget.transaction.counterParty);
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _referenceController =
        TextEditingController(text: widget.transaction.referenceNumber);
    _transactionType = widget.transaction.transactionType;
    _categoryId = widget.transaction.categoryId;
    _accountId = widget.transaction.accountId;
  }

  @override
  void dispose() {
    _counterPartyController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Transaction',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _counterPartyController,
            decoration: const InputDecoration(
              labelText: 'Counterparty *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount *',
              border: OutlineInputBorder(),
              prefixText: '₹',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TransactionType>(
            value: _transactionType,
            decoration: const InputDecoration(
              labelText: 'Transaction Type *',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: TransactionType.credit,
                child: Text('Credit'),
              ),
              DropdownMenuItem(
                value: TransactionType.debit,
                child: Text('Debit'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _transactionType = value);
              }
            },
          ),
          const SizedBox(height: 16),
          widget.categoriesAsync.when(
            data: (categories) {
              final categoryList = categories as List<Category>;
              return DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select Category'),
                  ),
                  ...categoryList.map((category) {
                    return DropdownMenuItem(
                      value: category.id.toString(),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(category.color),
                            radius: 12,
                            child: Text(
                              category.icon,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 16),
          widget.accountsAsync.when(
            data: (accounts) {
              final accountList = accounts as List<BankAccount>;
              return DropdownButtonFormField<String>(
                value: _accountId,
                decoration: const InputDecoration(
                  labelText: 'Account *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select Account'),
                  ),
                  ...accountList.map((account) {
                    return DropdownMenuItem(
                      value: account.id.toString(),
                      child: Text(account.accountName),
                    );
                  }),
                ],
                onChanged: (value) => setState(() => _accountId = value),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Reference Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _saveTransaction() {
    if (_counterPartyController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _categoryId == null ||
        _accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final updatedTransaction = widget.transaction.copyWith(
      counterParty: _counterPartyController.text,
      amount: amount,
      transactionType: _transactionType,
      categoryId: _categoryId!,
      accountId: _accountId!,
      description: _descriptionController.text,
      referenceNumber: _referenceController.text,
    );

    widget.onSave(updatedTransaction);
  }
}
