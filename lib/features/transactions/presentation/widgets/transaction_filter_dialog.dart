import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/transaction.dart';

class TransactionFilterDialog extends StatelessWidget {
  final TransactionType? selectedType;
  final DateTimeRange? selectedDateRange;
  final String? selectedCategoryId;
  final AsyncValue<List<dynamic>> categoriesAsync;
  final Function(
    TransactionType?,
    DateTimeRange?,
    String?,
  ) onApply;
  final VoidCallback onClear;

  const TransactionFilterDialog({
    super.key,
    required this.selectedType,
    required this.selectedDateRange,
    required this.selectedCategoryId,
    required this.categoriesAsync,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    TransactionType? type = selectedType;
    DateTimeRange? dateRange = selectedDateRange;
    String? categoryId = selectedCategoryId;

    return StatefulBuilder(
      builder: (context, setState) => Container(
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
              'Filter Transactions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Transaction Type Filter
            const Text('Transaction Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: type == null,
                  onSelected: (selected) => setState(() => type = null),
                ),
                FilterChip(
                  label: const Text('Income'),
                  selected: type == TransactionType.credit,
                  onSelected: (selected) =>
                      setState(() => type = TransactionType.credit),
                ),
                FilterChip(
                  label: const Text('Expense'),
                  selected: type == TransactionType.debit,
                  onSelected: (selected) =>
                      setState(() => type = TransactionType.debit),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date Range Filter
            const Text('Date Range'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All Time'),
                  selected: dateRange == null,
                  onSelected: (selected) => setState(() => dateRange = null),
                ),
                FilterChip(
                  label: const Text('Last 7 Days'),
                  selected: _isDateRangeSelected(dateRange, 7),
                  onSelected: (selected) =>
                      setState(() => dateRange = _getLastNDays(7)),
                ),
                FilterChip(
                  label: const Text('Last 30 Days'),
                  selected: _isDateRangeSelected(dateRange, 30),
                  onSelected: (selected) =>
                      setState(() => dateRange = _getLastNDays(30)),
                ),
                FilterChip(
                  label: const Text('Last 3 Months'),
                  selected: _isDateRangeSelected(dateRange, 90),
                  onSelected: (selected) =>
                      setState(() => dateRange = _getLastNDays(90)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Category Filter
            const Text('Category'),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) {
                final categoryList = categories as List<Category>;
                return Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: categoryId == null,
                      onSelected: (selected) => setState(() => categoryId = null),
                    ),
                    ...categoryList.map((category) {
                      return FilterChip(
                        label: Text(category.name),
                        selected: categoryId == category.id.toString(),
                        onSelected: (selected) =>
                            setState(() => categoryId = category.id.toString()),
                      );
                    }),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onClear,
                    child: const Text('Clear'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onApply(type, dateRange, categoryId),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _isDateRangeSelected(DateTimeRange? range, int days) {
    if (range == null) return false;
    final expectedRange = _getLastNDays(days);
    return range.start.year == expectedRange.start.year &&
        range.start.month == expectedRange.start.month &&
        range.start.day == expectedRange.start.day;
  }

  DateTimeRange _getLastNDays(int days) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - days);
    final end = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: start, end: end);
  }
}
