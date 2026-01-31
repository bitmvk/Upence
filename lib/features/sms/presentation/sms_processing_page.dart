import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sms.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/sms_parsing_pattern.dart';
import '../../../data/models/regex_sender_pattern.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../../../features/sms/services/sms_parsing_service.dart';

enum SelectionMode { amount, counterparty, reference }

class SMSProcessingPage extends ConsumerStatefulWidget {
  final SMSMessage sms;

  const SMSProcessingPage({super.key, required this.sms});

  @override
  ConsumerState<SMSProcessingPage> createState() => _SMSProcessingPageState();
}

class _SMSProcessingPageState extends ConsumerState<SMSProcessingPage> {
  String? _selectedAmount;
  final List<String> _selectedAmountWords = [];
  final List<String> _selectedCounterpartyWords = [];
  String get _selectedCounterparty => _selectedCounterpartyWords.join(' ');
  String? _selectedReference;
  final List<String> _selectedReferenceWords = [];
  TransactionType _transactionType = TransactionType.debit;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  final List<String> _selectedTagIds = [];
  String _description = '';
  SelectionMode? _selectionMode;
  bool _savePattern = false;
  bool _saveBankAccountForPattern = true;
  bool _saveCategoryForPattern = false;
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

  void _autoParseSMS() async {
    debugPrint('══════════════════════════════════════════════════════');
    debugPrint(
      '[AUTO PARSE] Starting auto-parse for SMS from: ${widget.sms.sender}',
    );
    debugPrint('  Message: ${widget.sms.message}');

    final patternsAsync = await ref.read(patternsProvider.future);
    final smsParsingService = SMSParsingService();

    debugPrint(
      '[AUTO PARSE] Total patterns loaded from DB: ${patternsAsync.length}',
    );

    final senderPatterns = patternsAsync
        .where((p) => p.senderIdentifier == widget.sms.sender && p.isActive)
        .toList();

    debugPrint(
      '[AUTO PARSE] Patterns matching sender "${widget.sms.sender}": ${senderPatterns.length}',
    );
    for (final p in senderPatterns) {
      debugPrint(
        '  - Pattern ID: ${p.id}, Name: ${p.patternName}, Active: ${p.isActive}',
      );
    }

    if (senderPatterns.isEmpty) {
      debugPrint('[AUTO PARSE] No matching patterns found for sender');
      debugPrint('══════════════════════════════════════════════════════');
      return;
    }

    final matchingPatterns = smsParsingService.findMatchingPatterns(
      widget.sms,
      senderPatterns,
    );

    if (matchingPatterns.isEmpty) {
      debugPrint('[AUTO PARSE] No patterns matched (score < 0.5 threshold)');
      debugPrint('══════════════════════════════════════════════════════');
      return;
    }

    final bestPattern = matchingPatterns.first;
    debugPrint(
      '[AUTO PARSE] Best pattern selected: ${bestPattern.patternName} (ID: ${bestPattern.id})',
    );

    final extractedFields = smsParsingService.extractFields(
      widget.sms.message,
      bestPattern,
    );

    debugPrint('[AUTO PARSE] Extracted fields:');
    debugPrint('  Amount: ${extractedFields['amount']}');
    debugPrint('  Counterparty: ${extractedFields['counterparty']}');
    debugPrint('  Reference: ${extractedFields['reference']}');

    setState(() {
      bool updated = false;

      if (extractedFields['amount'] != null &&
          extractedFields['amount']!.isNotEmpty) {
        _selectedAmount = extractedFields['amount'];
        _amountController.text = _selectedAmount!;
        // Also update the words list from the original message
        final words = widget.sms.message.split(' ');
        final amountValue = extractedFields['amount']!;
        _selectedAmountWords.clear();
        // Find all words that make up the amount
        for (final word in words) {
          final processedWord = word
              .replaceAll(RegExp(r'[a-zA-Z]'), '')
              .trim()
              .replaceAll(RegExp(r'^\.+|\.$'), '');
          if (processedWord.isNotEmpty && amountValue.contains(processedWord)) {
            _selectedAmountWords.add(word);
          }
        }
        debugPrint('[AUTO PARSE] ✓ Updated amount field: $_selectedAmount');
        debugPrint('[AUTO PARSE] ✓ Amount words: $_selectedAmountWords');
        updated = true;
      }

      if (extractedFields['counterparty'] != null &&
          extractedFields['counterparty']!.isNotEmpty) {
        final counterpartyWords = extractedFields['counterparty']!.split(' ');
        _selectedCounterpartyWords.clear();
        _selectedCounterpartyWords.addAll(counterpartyWords);
        _counterpartyController.text = extractedFields['counterparty']!;
        debugPrint(
          '[AUTO PARSE] ✓ Updated counterparty field: ${extractedFields['counterparty']}',
        );
        updated = true;
      }

      if (extractedFields['reference'] != null &&
          extractedFields['reference']!.isNotEmpty) {
        _selectedReference = extractedFields['reference'];
        _referenceController.text = _selectedReference!;
        // Also update the words list from the original message
        final words = widget.sms.message.split(' ');
        final referenceValue = extractedFields['reference']!;
        _selectedReferenceWords.clear();
        // Find all words that make up the reference
        for (final word in words) {
          final processedWord = word.replaceAll(RegExp(r'[^0-9]'), '');
          if (processedWord.isNotEmpty &&
              referenceValue.contains(processedWord)) {
            _selectedReferenceWords.add(word);
          }
        }
        debugPrint(
          '[AUTO PARSE] ✓ Updated reference field: $_selectedReference',
        );
        debugPrint('[AUTO PARSE] ✓ Reference words: $_selectedReferenceWords');
        updated = true;
      }

      _transactionType = bestPattern.transactionType;
      debugPrint('[AUTO PARSE] ✓ Updated transaction type: $_transactionType');

      if (bestPattern.defaultAccountId.isNotEmpty) {
        _selectedAccountId = bestPattern.defaultAccountId;
        debugPrint(
          '[AUTO PARSE] ✓ Updated default account: $_selectedAccountId',
        );
        updated = true;
      }

      debugPrint('[AUTO PARSE] Form updated: $updated');
      debugPrint('══════════════════════════════════════════════════════');
    });
  }

  Color _getSurfaceColor() {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.primarySurfaceLight
        : AppColors.primarySurfaceDark;
  }

  Widget _buildPatternSaveOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: const Text('Save this as a new pattern'),
              value: _savePattern,
              onChanged: (value) {
                setState(() {
                  _savePattern = value ?? false;
                  if (!_savePattern) {
                    _saveBankAccountForPattern = false;
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_savePattern)
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Save bank account for this pattern'),
                      value: _saveBankAccountForPattern,
                      onChanged: (value) {
                        setState(() {
                          _saveBankAccountForPattern = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Save category for this pattern'),
                      value: _saveCategoryForPattern,
                      onChanged: (value) {
                        setState(() {
                          _saveCategoryForPattern = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
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

      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(financialOverviewProvider);

      if (_selectedAccountId != null && _selectedAccountId!.isNotEmpty) {
        ref.invalidate(accountAnalyticsProvider(_selectedAccountId!));
      }

      var message = 'Transaction saved successfully';

      if (_savePattern) {
        final pattern = _createPatternFromForm();
        await ref.read(patternRepositoryProvider).insertPattern(pattern);
        ref.invalidate(patternsProvider);
        message += ', Pattern saved';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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

  SMSParsingPattern _createPatternFromForm() {
    final words = widget.sms.message.split(' ');

    final amountIndices = _selectedAmountWords
        .map((word) => words.indexOf(word))
        .where((index) => index >= 0)
        .toList();

    final counterpartyIndices = _selectedCounterpartyWords
        .map((word) => words.indexOf(word))
        .where((index) => index >= 0)
        .toList();

    final referenceIndices = _selectedReferenceWords
        .map((word) => words.indexOf(word))
        .where((index) => index >= 0)
        .toList();

    final smsParsingService = SMSParsingService();
    final messageStructure = smsParsingService.buildMessageStructure(
      widget.sms.message,
    );

    final pattern = SMSParsingPattern(
      senderIdentifier: widget.sms.sender,
      patternName: _selectedCounterparty.isNotEmpty
          ? 'Pattern for $_selectedCounterparty'
          : 'Pattern for ${widget.sms.sender}',
      messageStructure: messageStructure,
      amountPattern: amountIndices.isNotEmpty ? amountIndices.join(',') : '0',
      counterpartyPattern: counterpartyIndices.join(','),
      referencePattern: referenceIndices.isNotEmpty
          ? referenceIndices.join(',')
          : null,
      transactionType: _transactionType,
      defaultCategoryId: _saveCategoryForPattern
          ? (_selectedCategoryId ?? '')
          : '',
      defaultAccountId: _saveBankAccountForPattern
          ? (_selectedAccountId ?? '')
          : '',
      autoSelectAccount: _saveBankAccountForPattern,
      sampleSms: widget.sms.message,
      createdTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    debugPrint('══════════════════════════════════════════════════════');
    debugPrint('[PATTERN CREATION] Saving pattern to database:');
    debugPrint('  Sender: ${pattern.senderIdentifier}');
    debugPrint('  Name: ${pattern.patternName}');
    debugPrint('  Message structure: ${pattern.messageStructure}');
    debugPrint('  Amount word indices: ${pattern.amountPattern}');
    debugPrint('  Counterparty word indices: ${pattern.counterpartyPattern}');
    debugPrint(
      '  Reference word indices: ${pattern.referencePattern ?? "NULL"}',
    );
    debugPrint('  Transaction type: ${pattern.transactionType}');
    debugPrint('  Default category ID: ${pattern.defaultCategoryId}');
    debugPrint('  Default account ID: ${pattern.defaultAccountId}');
    debugPrint('  Auto-select account: ${pattern.autoSelectAccount}');
    debugPrint('  Sample SMS: ${pattern.sampleSms}');
    debugPrint('══════════════════════════════════════════════════════');

    return pattern;
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
            _buildPatternSaveOptions(),
            const SizedBox(height: 24),
            _buildAdvancedSection(),
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
    final isAmountSelected = _selectedAmountWords.contains(word);
    final isCounterpartySelected = _selectedCounterpartyWords.contains(word);
    final isReferenceSelected = _selectedReferenceWords.contains(word);

    final hasDigits = RegExp(r'\d').hasMatch(word);
    final isAmountMode = _selectionMode == SelectionMode.amount;
    final isReferenceMode = _selectionMode == SelectionMode.reference;
    final isNoModeSelected = _selectionMode == null;

    // Words are disabled if:
    // - No mode is selected, OR
    // - In amount mode and word has no digits, OR
    // - In reference mode and word has no digits
    final isWordDisabled =
        isNoModeSelected ||
        (isAmountMode && !hasDigits) ||
        (isReferenceMode && !hasDigits);

    final isSelected =
        isAmountSelected || isCounterpartySelected || isReferenceSelected;

    // Get the color for the selected type
    Color getSelectedColor() {
      if (isAmountSelected) return AppColors.primary;
      if (isCounterpartySelected) return AppColors.success;
      if (isReferenceSelected) return AppColors.warning;
      return Colors.transparent;
    }

    Color? backgroundColor;
    Color? textColor;

    if (isWordDisabled) {
      // Disabled words
      if (isSelected) {
        // Selected disabled word: color of selected type with opacity 0.2
        backgroundColor = getSelectedColor().withOpacity(0.2);
      } else {
        // Not selected disabled word: transparent
        backgroundColor = Colors.transparent;
      }
      // Text color: grey disabled
      textColor = AppColors.gray400;
    } else {
      // Enabled words
      if (isSelected) {
        // Selected enabled word: color of selected type
        backgroundColor = getSelectedColor();
      } else {
        // Not selected enabled word: grey with opacity 0.1 in light mode, 0.2 in dark mode
        final isLightMode = Theme.of(context).brightness == Brightness.light;
        backgroundColor = Colors.grey.withOpacity(isLightMode ? 0.1 : 0.2);
      }
      // Text color: white or black depending on light/dark mode
      textColor = Theme.of(context).brightness == Brightness.light
          ? AppColors.black
          : AppColors.white;
    }

    return InkWell(
      onTap: isWordDisabled ? null : () => _selectWordForMode(word),
      child: Chip(
        label: Text(word),
        backgroundColor: backgroundColor,
        labelStyle: TextStyle(
          color: textColor,
          fontWeight: isSelected ? FontWeight.bold : null,
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
          if (_selectedAmountWords.contains(word)) {
            _selectedAmountWords.remove(word);
          } else {
            _selectedAmountWords.add(word);
          }
          // Update the amount value by joining all selected words
          _selectedAmount = _selectedAmountWords
              .map(
                (w) => w
                    .replaceAll(RegExp(r'[a-zA-Z]'), '')
                    .trim()
                    .replaceAll(RegExp(r'^\.+|\.$'), ''),
              )
              .where((w) => w.isNotEmpty)
              .join('');
          _amountController.text = _selectedAmount ?? '';
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
          if (_selectedReferenceWords.contains(word)) {
            _selectedReferenceWords.remove(word);
          } else {
            _selectedReferenceWords.add(word);
          }
          // Update the reference value by joining all selected words
          _selectedReference = _selectedReferenceWords
              .map((w) => w.replaceAll(RegExp(r'[^0-9]'), ''))
              .where((w) => w.isNotEmpty)
              .join('');
          _referenceController.text = _selectedReference ?? '';
          break;
        case null:
          // No mode selected, do nothing
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
    return GestureDetector(
      onTap: () => setState(() {
        // Toggle the mode: if already selected, deselect it; otherwise select it
        _selectionMode = isSelected ? null : mode;
      }),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
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
            icon: Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTypeButton(
            label: 'Debit',
            type: TransactionType.debit,
            color: AppColors.expense,
            icon: Icons.arrow_upward,
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
    return GestureDetector(
      onTap: () => setState(() => _transactionType = type),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
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
            onChanged: (value) {
              setState(() {
                _selectedAmount = value;
                // Also update the words list based on the new value
                final words = widget.sms.message.split(' ');
                _selectedAmountWords.clear();
                for (final word in words) {
                  final processedWord = word
                      .replaceAll(RegExp(r'[a-zA-Z]'), '')
                      .trim()
                      .replaceAll(RegExp(r'^\.+|\.$'), '');
                  if (processedWord.isNotEmpty &&
                      (value.isEmpty || value.contains(processedWord))) {
                    _selectedAmountWords.add(word);
                  }
                }
              });
            },
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
            onChanged: (value) {
              setState(() {
                _selectedReference = value;
                // Also update the words list based on the new value
                final words = widget.sms.message.split(' ');
                _selectedReferenceWords.clear();
                for (final word in words) {
                  final processedWord = word.replaceAll(RegExp(r'[^0-9]'), '');
                  if (processedWord.isNotEmpty &&
                      (value.isEmpty || value.contains(processedWord))) {
                    _selectedReferenceWords.add(word);
                  }
                }
              });
            },
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
                controller: _descriptionController,
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
                onChanged: (value) => setState(() => _description = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Card(
      child: ExpansionTile(
        title: const Text(
          'Advanced',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: const Icon(Icons.tune),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Regex Sender Matching',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final patternsAsync = ref.watch(
                      regexSenderPatternsProvider,
                    );
                    return patternsAsync.when(
                      data: (patterns) {
                        if (patterns.isEmpty) {
                          return const Text(
                            'No regex patterns configured',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          );
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: patterns.map((pattern) {
                            return FilterChip(
                              label: Text(
                                pattern.regexPattern,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              selected: false,
                              onSelected: (selected) {
                                _showAddRegexPatternDialog(
                                  context,
                                  ref,
                                  pattern,
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () =>
                      _showAddRegexPatternDialog(context, ref, null),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Regex Pattern'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Examples:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r'• ^HDFC - Matches senders starting with HDFC'
                  '\n'
                  r'• .*-S$ - Matches senders ending with -S'
                  '\n'
                  r'• BANK - Matches senders containing BANK'
                  '\n'
                  r'• UPI - Matches senders containing UPI',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRegexPatternDialog(
    BuildContext context,
    WidgetRef ref,
    RegexSenderPattern? existingPattern,
  ) {
    final patternController = TextEditingController(
      text: existingPattern?.regexPattern ?? widget.sms.sender,
    );
    final descriptionController = TextEditingController(
      text: existingPattern?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existingPattern == null ? 'Add Regex Pattern' : 'Edit Regex Pattern',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: patternController,
              decoration: const InputDecoration(
                labelText: 'Regex Pattern *',
                hintText: 'e.g., ^HDFC',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., HDFC Bank senders',
              ),
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
              if (patternController.text.trim().isEmpty) {
                return;
              }

              final pattern = RegexSenderPattern(
                id: existingPattern?.id ?? 0,
                regexPattern: patternController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
                priority: 0,
                isActive: true,
                createdTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

              final repo = ref.read(regexSenderPatternsRepositoryProvider);
              if (existingPattern == null) {
                await repo.insertPattern(pattern);
              } else {
                await repo.updatePattern(pattern);
              }

              ref.invalidate(regexSenderPatternsProvider);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      existingPattern == null
                          ? 'Pattern added'
                          : 'Pattern updated',
                    ),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
