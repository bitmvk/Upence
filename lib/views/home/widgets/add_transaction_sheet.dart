import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upence/core/ui/icon_mapper.dart';
import 'package:upence/core/utils/formatters.dart';
import 'package:upence/data/local/database/database.dart';

class AddTransactionSheet extends StatefulWidget {
  final List<Category> categories;
  final List<BankAccount> accounts;
  final List<Tag> tags;
  final Sms? prefillSms;
  final void Function(Transaction, List<int> tagIds) onSave;

  const AddTransactionSheet({
    super.key,
    required this.categories,
    required this.accounts,
    required this.tags,
    this.prefillSms,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required List<Category> categories,
    required List<BankAccount> accounts,
    required List<Tag> tags,
    Sms? prefillSms,
    required void Function(Transaction, List<int> tagIds) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(
        categories: categories,
        accounts: accounts,
        tags: tags,
        prefillSms: prefillSms,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _payeeController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.debit;
  Category? _selectedCategory;
  BankAccount? _selectedAccount;
  final List<Tag> _selectedTags = [];
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _prefillFromSms();
    _setDefaultAccount();
  }

  void _prefillFromSms() {
    if (widget.prefillSms == null) return;

    final body = widget.prefillSms!.body;
    final amountMatch = RegExp(
      r'(?:Rs\.?|INR|₹)\s*(\d+(?:,\d+)*(?:\.\d+)?)',
    ).firstMatch(body);
    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)!.replaceAll(',', '');
      final amount = double.tryParse(amountStr);
      if (amount != null) {
        _amountController.text = (amount * 100).toInt().toString();
      }
    }

    if (body.toLowerCase().contains('credit') ||
        body.toLowerCase().contains('received') ||
        body.toLowerCase().contains('deposited')) {
      _type = TransactionType.credit;
    }

    _descriptionController.text = 'From SMS: ${widget.prefillSms!.sender}';
    _selectedDate = widget.prefillSms!.receivedAt;
  }

  void _setDefaultAccount() {
    if (widget.accounts.isNotEmpty) {
      _selectedAccount = widget.accounts.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _payeeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: bottomPadding + 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(context),
                    const SizedBox(height: 20),
                    _buildAmountField(context),
                    const SizedBox(height: 16),
                    _buildPayeeField(context),
                    const SizedBox(height: 16),
                    _buildDropdowns(context),
                    const SizedBox(height: 16),
                    _buildDescriptionField(context),
                    const SizedBox(height: 16),
                    _buildDatePicker(context),
                    if (widget.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildTagSelector(context),
                    ],
                    const SizedBox(height: 24),
                    _buildSaveButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.add_circle_outline_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Add Transaction',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              context,
              label: 'Expense',
              icon: Icons.arrow_upward_rounded,
              value: TransactionType.debit,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTypeButton(
              context,
              label: 'Income',
              icon: Icons.arrow_downward_rounded,
              value: TransactionType.credit,
              color: colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required TransactionType value,
    required Color color,
  }) {
    final isSelected = _type == value;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.surface
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.surface
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Amount (in paise)',
        prefixText: '₹ ',
        prefixStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildPayeeField(BuildContext context) {
    return TextFormField(
      controller: _payeeController,
      decoration: InputDecoration(
        labelText: 'Payee / Merchant',
        prefixIcon: const Icon(Icons.person_outline_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a payee name';
        }
        return null;
      },
    );
  }

  Widget _buildDropdowns(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCategoryDropdown(context)),
        const SizedBox(width: 12),
        Expanded(child: _buildAccountDropdown(context)),
      ],
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return DropdownButtonFormField<Category>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: widget.categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Color(category.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(category.name, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
    );
  }

  Widget _buildAccountDropdown(BuildContext context) {
    return DropdownButtonFormField<BankAccount>(
      initialValue: _selectedAccount,
      decoration: InputDecoration(
        labelText: 'Account',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: widget.accounts.map((account) {
        return DropdownMenuItem(
          value: account,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconMap[account.icon] ?? Icons.account_balance_rounded,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(account.name, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedAccount = value),
      validator: (value) {
        if (value == null) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (optional)',
        prefixIcon: const Icon(Icons.notes_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: 2,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              'Date: ${DateFormatter.formatFullDate(_selectedDate)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.tags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            final tagColor = Color(tag.color);

            return FilterChip(
              selected: isSelected,
              label: Text(tag.name),
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimary : tagColor,
                fontWeight: FontWeight.w500,
              ),
              avatar: isSelected
                  ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                  : null,
              selectedColor: tagColor,
              backgroundColor: tagColor.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? tagColor
                      : tagColor.withValues(alpha: 0.3),
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: _isSaving ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: _type == TransactionType.credit
              ? colorScheme.tertiary
              : colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Save Transaction',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final amount = int.tryParse(_amountController.text) ?? 0;

    final transaction = Transaction(
      id: 0,
      accountId: _selectedAccount!.id,
      categoryId: _selectedCategory?.id,
      smsId: widget.prefillSms?.id,
      payee: _payeeController.text,
      amount: amount,
      type: _type.value,
      reference: null,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      occurredAt: _selectedDate,
    );

    final tagIds = _selectedTags.map((t) => t.id).toList();
    widget.onSave(transaction, tagIds);
    Navigator.pop(context);
  }
}
