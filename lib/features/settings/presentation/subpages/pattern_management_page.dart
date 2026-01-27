import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/sms_parsing_pattern.dart';
import '../../../../data/models/transaction.dart';

class PatternManagementPage extends ConsumerStatefulWidget {
  const PatternManagementPage({super.key});

  @override
  ConsumerState<PatternManagementPage> createState() =>
      _PatternManagementPageState();
}

class _PatternManagementPageState extends ConsumerState<PatternManagementPage> {
  @override
  Widget build(BuildContext context) {
    final patternsAsync = ref.watch(patternsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Patterns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPatternDialog(),
          ),
        ],
      ),
      body: patternsAsync.when(
        data: (patterns) {
          if (patterns.isEmpty) {
            return const Center(child: Text('No patterns yet'));
          }

          return ListView.builder(
            itemCount: patterns.length,
            itemBuilder: (context, index) {
              final pattern = patterns[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: pattern.isActive
                      ? AppColors.income
                      : AppColors.gray400,
                  child: Icon(
                    pattern.isActive ? Icons.check : Icons.close,
                    color: Colors.white,
                  ),
                ),
                title: Text(pattern.patternName),
                subtitle: Text('Sender: ${pattern.senderName}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditPatternDialog(pattern),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: AppColors.expense,
                      onPressed: () => _showDeleteDialog(pattern),
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

  void _showAddPatternDialog() {
    _showPatternDialog(null);
  }

  void _showEditPatternDialog(SMSParsingPattern pattern) {
    _showPatternDialog(pattern);
  }

  void _showPatternDialog(SMSParsingPattern? pattern) {
    final nameController = TextEditingController(
      text: pattern?.patternName ?? '',
    );
    final senderController = TextEditingController(
      text: pattern?.senderIdentifier ?? '',
    );
    final structureController = TextEditingController(
      text: pattern?.messageStructure ?? '',
    );
    final amountController = TextEditingController(
      text: pattern?.amountPattern ?? '',
    );
    final counterpartyController = TextEditingController(
      text: pattern?.counterpartyPattern ?? '',
    );
    final referenceController = TextEditingController(
      text: pattern?.referencePattern ?? '',
    );
    final sampleController = TextEditingController(
      text: pattern?.sampleSms ?? '',
    );

    TransactionType selectedType =
        pattern?.transactionType ?? TransactionType.debit;
    bool isActive = pattern?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(pattern == null ? 'Add Pattern' : 'Edit Pattern'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Pattern Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: senderController,
                  decoration: const InputDecoration(
                    labelText: 'Sender Identifier',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: structureController,
                  decoration: const InputDecoration(
                    labelText: 'Message Structure',
                    hintText: 'e.g., [TEXT],[NUMBER],[TEXT]',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount Pattern',
                    hintText: 'e.g., 0 (word index)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: counterpartyController,
                  decoration: const InputDecoration(
                    labelText: 'Counterparty Pattern',
                    hintText: 'e.g., 1,2 (word indices)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Reference Pattern',
                    hintText: 'e.g., 3 (word index)',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Transaction Type'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RadioListTile<TransactionType>(
                      title: const Text('Credit'),
                      value: TransactionType.credit,
                      groupValue: selectedType,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedType = value);
                        }
                      },
                    ),
                    RadioListTile<TransactionType>(
                      title: const Text('Debit'),
                      value: TransactionType.debit,
                      groupValue: selectedType,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedType = value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sampleController,
                  decoration: const InputDecoration(labelText: 'Sample SMS'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    senderController.text.isEmpty) {
                  return;
                }

                final repo = ref.read(patternRepositoryProvider);
                final now = DateTime.now().millisecondsSinceEpoch;

                if (pattern == null) {
                  await repo.insertPattern(
                    SMSParsingPattern(
                      id: 0,
                      senderIdentifier: senderController.text,
                      patternName: nameController.text,
                      messageStructure: structureController.text,
                      amountPattern: amountController.text,
                      counterpartyPattern: counterpartyController.text,
                      datePattern: referenceController.text,
                      referencePattern: referenceController.text,
                      transactionType: selectedType,
                      isActive: isActive,
                      defaultCategoryId: '',
                      defaultAccountId: '',
                      autoSelectAccount: false,
                      senderName: senderController.text,
                      sampleSms: sampleController.text,
                      createdTimestamp: now,
                      lastUsedTimestamp: null,
                    ),
                  );
                } else {
                  await repo.updatePattern(
                    pattern.copyWith(
                      senderIdentifier: senderController.text,
                      patternName: nameController.text,
                      messageStructure: structureController.text,
                      amountPattern: amountController.text,
                      counterpartyPattern: counterpartyController.text,
                      datePattern: referenceController.text,
                      referencePattern: referenceController.text,
                      transactionType: selectedType,
                      isActive: isActive,
                      senderName: senderController.text,
                      sampleSms: sampleController.text,
                    ),
                  );
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(patternsProvider);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(SMSParsingPattern pattern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pattern'),
        content: Text(
          'Are you sure you want to delete "${pattern.patternName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(patternRepositoryProvider);
              await repo.deletePattern(pattern.id);
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(patternsProvider);
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
