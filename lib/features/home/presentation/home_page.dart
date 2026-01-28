import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../sms/presentation/unprocessed_sms_page.dart';
import 'widgets/financial_overview_card.dart';
import 'widgets/transaction_list_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTransactionsAsync = ref.watch(recentTransactionsProvider);
    final currencyAsync = ref.watch(currencyProvider);
    final financialOverviewAsync = ref.watch(financialOverviewProvider);

    return currencyAsync.when(
      data: (currency) {
        return financialOverviewAsync.when(
          data: (overview) {
            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () => _refreshData(ref),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: FinancialOverviewCard(
                          balance: overview.balance,
                          income: overview.income,
                          expense: overview.expense,
                          currency: currency,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildProcessSMSBanner(context)),
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
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
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
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
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
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildProcessSMSBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UnprocessedSMSPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.sms,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Process SMS',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tap to process unprocessed SMS messages',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(financialOverviewProvider);
  }
}
