import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sms.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../services/sms_parsing_service.dart';

class SMSProcessingPage extends ConsumerStatefulWidget {
  final SMSMessage sms;

  const SMSProcessingPage({super.key, required this.sms});

  @override
  ConsumerState<SMSProcessingPage> createState() => _SMSProcessingPageState();
}

class _SMSProcessingPageState extends ConsumerState<SMSProcessingPage> {
  String? _selectedAmount;
  String? _selectedCounterparty;
  String? _selectedReference;
  TransactionType _transactionType = TransactionType.debit;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  final List<String> _selectedTagIds = [];
  String _description = '';

  @override
  void initState() {
    super.initState();
    _autoParseSMS();
  }

  void _autoParseSMS() {
    // TODO: Get patterns from database and try to match
  }

  void _saveTransaction() async {
    if (_selectedAmount == null || _selectedCounterparty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select amount and counterparty')),
      );
      return;
    }

    final amount = double.tryParse(_selectedAmount ?? '0');
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final transaction = Transaction(
      counterParty: _selectedCounterparty!,
      amount: amount,
      timestamp: widget.sms.dateTime,
      categoryId: _selectedCategoryId ?? '',
      description: _description,
      accountId: _selectedAccountId ?? '',
      transactionType: _transactionType,
      referenceNumber: _selectedReference ?? '',
    );

    try {
      await ref
          .read(transactionRepositoryProvider)
          .insertTransaction(transaction);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process SMS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTransaction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSMSMessage(),
            const SizedBox(height: 24),
            _buildTransactionTypeToggle(),
            const SizedBox(height: 24),
            _buildAmountSelector(),
            const SizedBox(height: 24),
            _buildCounterpartySelector(),
            const SizedBox(height: 24),
            _buildReferenceSelector(),
            const SizedBox(height: 24),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            _buildAccountSelector(),
            const SizedBox(height: 24),
            _buildTagSelector(),
            const SizedBox(height: 24),
            _buildDescriptionField(),
          ],
        ),
      ),
    );
  }

  Widget _buildSMSMessage() {
    final words = widget.sms.message.split(' ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: ${widget.sms.sender}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: words.map((word) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 2,
                  ),
                  child: _buildWordChip(word),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordChip(String word) {
    Color? backgroundColor;
    Color? textColor;

    if (word == _selectedAmount) {
      backgroundColor = AppColors.primary.withOpacity(0.2);
      textColor = AppColors.primary;
    } else if (word == _selectedCounterparty) {
      backgroundColor = AppColors.success.withOpacity(0.2);
      textColor = AppColors.success;
    } else if (word == _selectedReference) {
      backgroundColor = AppColors.warning.withOpacity(0.2);
      textColor = AppColors.warning;
    }

    return InkWell(
      onTap: () => _showWordSelectionDialog(word),
      child: Chip(
        label: Text(word),
        backgroundColor: backgroundColor,
        labelStyle: TextStyle(color: textColor),
      ),
    );
  }

  void _showWordSelectionDialog(String word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select field for: $word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Amount'),
              onTap: () {
                setState(() => _selectedAmount = word);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Counterparty'),
              onTap: () {
                setState(() => _selectedCounterparty = word);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Reference'),
              onTap: () {
                setState(() => _selectedReference = word);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                label: 'Credit',
                type: TransactionType.credit,
                color: AppColors.income,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTypeButton(
                label: 'Debit',
                type: TransactionType.debit,
                color: AppColors.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required TransactionType type,
    required Color color,
  }) {
    final isSelected = _transactionType == type;
    return InkWell(
      onTap: () => setState(() => _transactionType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : null,
          border: Border.all(
            color: isSelected ? color : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? color : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefixText: '₹',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => _selectedAmount = value),
              controller: TextEditingController(text: _selectedAmount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterpartySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Counterparty',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter counterparty',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  setState(() => _selectedCounterparty = value),
              controller: TextEditingController(text: _selectedCounterparty),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reference Number',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter reference number (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _selectedReference = value),
              controller: TextEditingController(text: _selectedReference),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoriesProvider);
                return categoriesAsync.when(
                  data: (categories) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: 'Select category',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedCategoryId,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id.toString(),
                          child: Row(
                            children: [
                              Text(category.icon),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategoryId = value),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final accountsAsync = ref.watch(bankAccountsProvider);
                return accountsAsync.when(
                  data: (accounts) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: 'Select account',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedAccountId,
                      items: accounts.map((account) {
                        return DropdownMenuItem(
                          value: account.id.toString(),
                          child: Text(account.accountName),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedAccountId = value),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final tagsAsync = ref.watch(tagsProvider);
                return tagsAsync.when(
                  data: (tags) {
                    return Wrap(
                      spacing: 8,
                      children: tags.map((tag) {
                        final isSelected = _selectedTagIds.contains(
                          tag.id.toString(),
                        );
                        return FilterChip(
                          label: Text(tag.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTagIds.add(tag.id.toString());
                              } else {
                                _selectedTagIds.remove(tag.id.toString());
                              }
                            });
                          },
                          selectedColor: Color(
                            int.parse(tag.color),
                          ).withOpacity(0.2),
                          checkmarkColor: Color(int.parse(tag.color)),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => setState(() => _description = value),
              controller: TextEditingController(text: _description),
            ),
          ],
        ),
      ),
    );
  }
}
