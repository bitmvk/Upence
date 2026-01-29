import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/page_wrapper.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction.dart';
import '../../home/presentation/widgets/transaction_list_item.dart';
import 'widgets/transaction_filter_dialog.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  TransactionType? _selectedType;
  DateTimeRange? _selectedDateRange;
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final currencyAsync = ref.watch(currencyProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return currencyAsync.when(
      data: (currency) {
        return PageWrapper(
          title: const Text('Transactions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context, categoriesAsync),
            ),
          ],
          body: transactionsAsync.when(
            data: (transactions) {
              final filteredTransactions = _filterTransactions(transactions);

              if (filteredTransactions.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () => _refreshData(ref),
                child: ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return TransactionListItem(
                      transaction: transaction,
                      onTap: () {
                        // TODO: Navigate to transaction details
                        Navigator.pushNamed(
                          context,
                          '/transaction/${transaction.id}',
                        );
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final hasFilters =
        _selectedType != null || _selectedDateRange != null || _selectedCategoryId != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list_off : Icons.receipt_long,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? 'No transactions match your filters'
                : 'No transactions yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    // Filter by transaction type
    if (_selectedType != null) {
      filtered = filtered
          .where((t) => t.transactionType == _selectedType)
          .toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((t) {
        final transactionDate = DateTime(
          t.timestamp.year,
          t.timestamp.month,
          t.timestamp.day,
        );
        return !transactionDate.isBefore(_selectedDateRange!.start) &&
            !transactionDate.isAfter(_selectedDateRange!.end);
      }).toList();
    }

    // Filter by category
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((t) => t.categoryId == _selectedCategoryId)
          .toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedDateRange = null;
      _selectedCategoryId = null;
    });
  }

  void _showFilterDialog(
    BuildContext context,
    AsyncValue<List<dynamic>> categoriesAsync,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionFilterDialog(
        selectedType: _selectedType,
        selectedDateRange: _selectedDateRange,
        selectedCategoryId: _selectedCategoryId,
        categoriesAsync: categoriesAsync,
        onApply: (type, dateRange, categoryId) {
          setState(() {
            _selectedType = type;
            _selectedDateRange = dateRange;
            _selectedCategoryId = categoryId;
          });
          Navigator.pop(context);
        },
        onClear: () {
          _clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(transactionListProvider);
  }
}
