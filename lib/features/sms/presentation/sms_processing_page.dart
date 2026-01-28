import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sms.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/custom_dropdown.dart';

enum SelectionMode { amount, counterparty, reference }

class SMSProcessingPage extends ConsumerStatefulWidget {
  final SMSMessage sms;

  const SMSProcessingPage({super.key, required this.sms});

  @override
  ConsumerState<SMSProcessingPage> createState() => _SMSProcessingPageState();
}

class _SMSProcessingPageState extends ConsumerState<SMSProcessingPage> {
  String? _selectedAmount;
  String? _selectedAmountWord;
  final List<String> _selectedCounterpartyWords = [];
  String get _selectedCounterparty => _selectedCounterpartyWords.join(' ');
  String? _selectedReference;
  String? _selectedReferenceWord;
  TransactionType _transactionType = TransactionType.debit;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  final List<String> _selectedTagIds = [];
  String _description = '';
  SelectionMode _selectionMode = SelectionMode.amount;
  late TextEditingController _amountController;
  late TextEditingController _counterpartyController;
  late TextEditingController _referenceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _selectedAmount);
    _counterpartyController = TextEditingController(
      text: _selectedCounterparty,
    );
    _referenceController = TextEditingController(text: _selectedReference);
    _descriptionController = TextEditingController(text: _description);
    _autoParseSMS();
  }

  void _autoParseSMS() {
    // TODO: Get patterns from database and try to match
  }

  Color _getSurfaceColor() {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.primarySurfaceLight
        : AppColors.primarySurfaceDark;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _counterpartyController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    if (_selectedAmount == null || _selectedCounterpartyWords.isEmpty) {
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
      counterParty: _selectedCounterparty,
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
      appBar: AppBar(title: const Text('Process SMS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSMSMessage(),
            const SizedBox(height: 24),
            _buildTransactionFormCard(),
            const SizedBox(height: 24),
            _buildTagSelector(),
            const SizedBox(height: 24),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
            const SizedBox(height: 16),
            _buildSelectionModeToggles(),
            const SizedBox(height: 16),
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
    final isAmountSelected = word == _selectedAmountWord;
    final isCounterpartySelected = _selectedCounterpartyWords.contains(word);
    final isReferenceSelected = word == _selectedReferenceWord;

    final hasDigits = RegExp(r'\d').hasMatch(word);
    final isAmountMode = _selectionMode == SelectionMode.amount;
    final isReferenceMode = _selectionMode == SelectionMode.reference;
    final isWordDisabledForAmount = isAmountMode && !hasDigits;
    final isWordDisabledForReference = isReferenceMode && !hasDigits;
    final isWordDisabled =
        isWordDisabledForAmount || isWordDisabledForReference;

    Color? backgroundColor;

    if (isAmountSelected) {
      backgroundColor = AppColors.primary;
    } else if (isCounterpartySelected) {
      backgroundColor = AppColors.success;
    } else if (isReferenceSelected) {
      backgroundColor = AppColors.warning;
    }

    return InkWell(
      onTap: isWordDisabled ? null : () => _selectWordForMode(word),
      child: Chip(
        label: Text(word),
        backgroundColor: isWordDisabled
            ? Colors.grey.withOpacity(0.1)
            : (backgroundColor ?? AppColors.primary.withOpacity(0.15)),
        labelStyle: TextStyle(
          color: isWordDisabled
              ? Colors.grey
              : Theme.of(context).colorScheme.onSurface,
        ),
        side: BorderSide.none,
        elevation: 0,
      ),
    );
  }

  void _selectWordForMode(String word) {
    setState(() {
      switch (_selectionMode) {
        case SelectionMode.amount:
          final processedWord = word
              .replaceAll(RegExp(r'[a-zA-Z]'), '')
              .trim()
              .replaceAll(RegExp(r'^\.+|\.$'), '');
          if (processedWord.isNotEmpty) {
            if (_selectedAmountWord == word) {
              _selectedAmount = null;
              _selectedAmountWord = null;
              _amountController.text = '';
            } else {
              _selectedAmount = processedWord;
              _selectedAmountWord = word;
              _amountController.text = processedWord;
            }
          }
          break;
        case SelectionMode.counterparty:
          if (_selectedCounterpartyWords.contains(word)) {
            _selectedCounterpartyWords.remove(word);
          } else {
            _selectedCounterpartyWords.add(word);
          }
          _counterpartyController.text = _selectedCounterpartyWords.join(' ');
          break;
        case SelectionMode.reference:
          final processedWord = word.replaceAll(RegExp(r'[^0-9]'), '');
          if (processedWord.isNotEmpty) {
            if (_selectedReferenceWord == word) {
              _selectedReference = null;
              _selectedReferenceWord = null;
              _referenceController.text = '';
            } else {
              _selectedReference = processedWord;
              _selectedReferenceWord = word;
              _referenceController.text = processedWord;
            }
          }
          break;
      }
    });
  }

  Widget _buildTransactionFormCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionTypeToggle(),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildCounterpartyField(),
            const SizedBox(height: 16),
            _buildReferenceField(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildAccountSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionModeToggles() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            label: 'Amount',
            mode: SelectionMode.amount,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToggleButton(
            label: 'Counterparty',
            mode: SelectionMode.counterparty,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToggleButton(
            label: 'Reference',
            mode: SelectionMode.reference,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required SelectionMode mode,
    required Color color,
  }) {
    final isSelected = _selectionMode == mode;
    return InkWell(
      onTap: () => setState(() => _selectionMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(1.0) : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            label: 'Credit',
            type: TransactionType.credit,
            color: AppColors.income,
            icon: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTypeButton(
            label: 'Debit',
            type: TransactionType.debit,
            color: AppColors.expense,
            icon: Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String label,
    required TransactionType type,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _transactionType == type;
    return InkWell(
      onTap: () => setState(() => _transactionType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(1.0) : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : null, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _getSurfaceColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter amount',
              hintStyle: TextStyle(color: AppColors.gray500),
              prefixText: '₹',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            keyboardType: TextInputType.number,
            controller: _amountController,
            onChanged: (value) => setState(() => _selectedAmount = value),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterpartyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Counterparty',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _getSurfaceColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter counterparty',
              hintStyle: TextStyle(color: AppColors.gray500),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            controller: _counterpartyController,
            onChanged: (value) => setState(() {
              _selectedCounterpartyWords.clear();
              _selectedCounterpartyWords.addAll(
                value.split(' ').where((w) => w.isNotEmpty),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reference Number',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _getSurfaceColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter reference number (optional)',
              hintStyle: TextStyle(color: AppColors.gray500),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            controller: _referenceController,
            onChanged: (value) => setState(() => _selectedReference = value),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoriesProvider);
            return categoriesAsync.when(
              data: (categories) {
                return CustomDropdown<String>(
                  hint: 'Select category',
                  value: _selectedCategoryId,
                  fillColor: _getSurfaceColor(),
                  dropdownColor: _getSurfaceColor(),
                  menuMaxHeight: 300,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id.toString(),
                      child: Row(
                        children: [
                          Icon(
                            _getIconData(category.icon),
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategoryId = value),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_cart': Icons.shopping_cart,
      'receipt': Icons.receipt,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'local_grocery_store': Icons.local_grocery_store,
      'home': Icons.home,
      'work': Icons.work,
      'flight': Icons.flight,
      'fitness_center': Icons.fitness_center,
      'school': Icons.school,
      'phone': Icons.phone,
      'more_horiz': Icons.more_horiz,
    };
    return iconMap[iconName] ?? Icons.label;
  }

  Widget _buildAccountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final accountsAsync = ref.watch(bankAccountsProvider);
            return accountsAsync.when(
              data: (accounts) {
                return CustomDropdown<String>(
                  hint: 'Select account',
                  value: _selectedAccountId,
                  fillColor: _getSurfaceColor(),
                  dropdownColor: _getSurfaceColor(),
                  menuMaxHeight: 300,
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        ),
      ],
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
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, child) {
                final tagsAsync = ref.watch(tagsProvider);
                return tagsAsync.when(
                  data: (tags) {
                    return SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) {
                          final isSelected = _selectedTagIds.contains(
                            tag.id.toString(),
                          );
                          return Padding(
                            padding: EdgeInsets.zero,
                            child: FilterChip(
                              label: Text(
                                tag.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
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
                                _parseColor(tag.color),
                              ).withOpacity(0.2),
                              checkmarkColor: Color(_parseColor(tag.color)),
                            ),
                          );
                        }).toList(),
                      ),
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

  int _parseColor(String colorString) {
    try {
      return int.parse(colorString.replaceFirst('#', '0xFF'));
    } catch (e) {
      return 0xFF4361EE;
    }
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
            Container(
              decoration: BoxDecoration(
                color: _getSurfaceColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter description (optional)',
                  hintStyle: TextStyle(color: AppColors.gray500),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
                controller: _descriptionController,
                onChanged: (value) => setState(() => _description = value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
