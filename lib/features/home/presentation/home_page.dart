import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import 'widgets/financial_overview_card.dart';
import 'widgets/transaction_list_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTransactionsAsync = ref.watch(recentTransactionsProvider);
    final currencyAsync = ref.watch(currencyProvider);

    return currencyAsync.when(
      data: (currency) {
        return RefreshIndicator(
          onRefresh: () => _refreshData(ref),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FinancialOverviewCard(
                    balance: 0.0, // TODO: Get from provider
                    income: 0.0, // TODO: Get from provider
                    expense: 0.0, // TODO: Get from provider
                    currency: currency,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Navigate to all transactions
                        },
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                ),
              ),
              recentTransactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                // TODO: Navigate to SMS processing
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Transaction'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final transaction = transactions[index];
                      return TransactionListItem(
                        transaction: transaction,
                        onTap: () {
                          // TODO: Show transaction details
                        },
                      );
                    }, childCount: transactions.length),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(recentTransactionsProvider);
  }
}
