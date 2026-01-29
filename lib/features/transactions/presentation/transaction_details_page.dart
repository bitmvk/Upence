import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/page_wrapper.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction.dart';
import 'widgets/edit_transaction_dialog.dart';

class TransactionDetailsPage extends ConsumerWidget {
  final int transactionId;

  const TransactionDetailsPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionRepository = ref.read(transactionRepositoryProvider);
    final currencyAsync = ref.watch(currencyProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(bankAccountsProvider);
    final tagsAsync = ref.watch(tagsProvider);

    return currencyAsync.when(
      data: (currency) {
        return FutureBuilder<Transaction?>(
          future: transactionRepository.getTransactionById(transactionId),
          builder: (context, snapshot) {
            final transaction = snapshot.data;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || transaction == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Transaction Details')),
                body: const Center(child: Text('Transaction not found')),
              );
            }

            return PageWrapper(
              title: const Text('Transaction Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(
                    context,
                    ref,
                    transaction,
                    categoriesAsync,
                    accountsAsync,
                    tagsAsync,
                  ),
                  tooltip: 'Edit',
                ),
                PopupMenuButton<String>(
                  onSelected: (choice) => _handleMenuChoice(
                    context,
                    ref,
                    choice,
                    transaction,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: ListTile(
                        leading: Icon(Icons.share),
                        title: Text('Share'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: ListTile(
                        leading: Icon(Icons.content_copy),
                        title: Text('Duplicate'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountCard(context, transaction, currency),
                    const SizedBox(height: 24),
                    _buildDetailsSection(context, transaction),
                    const SizedBox(height: 24),
                    _buildMetaSection(context, transaction),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildAmountCard(
    BuildContext context,
    Transaction transaction,
    String currency,
  ) {
    final isCredit = transaction.transactionType == TransactionType.credit;
    final amountColor = isCredit
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final amountPrefix = isCredit ? '+' : '-';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '$amountPrefix${CurrencyFormatter.format(transaction.amount, symbol: currency)}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.counterParty,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, Transaction transaction) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'Date',
              DateFormatter.formatDate(transaction.timestamp),
            ),
            _buildDetailRow(
              context,
              Icons.category,
              'Type',
              transaction.transactionType == TransactionType.credit
                  ? 'Credit'
                  : 'Debit',
            ),
            _buildDetailRow(
              context,
              Icons.description,
              'Description',
              transaction.description.isNotEmpty
                  ? transaction.description
                  : 'No description',
            ),
            if (transaction.referenceNumber.isNotEmpty)
              _buildDetailRow(
                context,
                Icons.confirmation_number,
                'Reference',
                transaction.referenceNumber,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaSection(BuildContext context, Transaction transaction) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meta Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            _buildDetailRow(
              context,
              Icons.label,
              'Category ID',
              transaction.categoryId,
            ),
            _buildDetailRow(
              context,
              Icons.account_balance,
              'Account ID',
              transaction.accountId,
            ),
            _buildDetailRow(
              context,
              Icons.fingerprint,
              'Transaction ID',
              transaction.id.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
    AsyncValue<List<dynamic>> categoriesAsync,
    AsyncValue<List<dynamic>> accountsAsync,
    AsyncValue<List<dynamic>> tagsAsync,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditTransactionDialog(
        transaction: transaction,
        categoriesAsync: categoriesAsync,
        accountsAsync: accountsAsync,
        tagsAsync: tagsAsync,
        onSave: (updatedTransaction) async {
          final repo = ref.read(transactionRepositoryProvider);
          await repo.updateTransaction(updatedTransaction);
          ref.invalidate(transactionListProvider);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _handleMenuChoice(
    BuildContext context,
    WidgetRef ref,
    String choice,
    Transaction transaction,
  ) {
    switch (choice) {
      case 'share':
        // TODO: Implement share functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share functionality coming soon')),
        );
        break;
      case 'duplicate':
        // TODO: Implement duplicate functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duplicate functionality coming soon')),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, ref, transaction);
        break;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this transaction with ${transaction.counterParty}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final repo = ref.read(transactionRepositoryProvider);
              await repo.deleteTransaction(transaction.id);
              ref.invalidate(transactionListProvider);
              if (context.mounted) {
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
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
