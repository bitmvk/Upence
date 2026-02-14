import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upence/core/ui/widgets/app_drawer.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/views/home/home_view_model.dart';
import 'package:upence/views/home/widgets/add_transaction_sheet.dart';
import 'package:upence/views/home/widgets/month_selector.dart';
import 'package:upence/views/home/widgets/summary_cards_row.dart';
import 'package:upence/views/home/widgets/transaction_list_item.dart';
import 'package:upence/views/home/widgets/unprocessed_sms_card.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/'),
      body: RefreshIndicator(
        onRefresh: viewModel.refresh,
        edgeOffset: 80,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, state, viewModel),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (state.isLoading && state.recentTransactions.isEmpty)
                    const _LoadingShimmer()
                  else ...[
                    SummaryCardsRow(
                      totalIncome: state.totalIncome,
                      totalExpense: state.totalExpense,
                      netSpend: state.netSpend,
                      isLoading: state.isLoading,
                    ),
                    const SizedBox(height: 16),
                    UnprocessedSmsCard(
                      smsList: state.unprocessedSms,
                      isLoading: state.isLoadingSms,
                      onCreateTransaction: (sms) =>
                          _showAddTransactionFromSms(sms),
                      onMarkAsNotTransaction: (sms) =>
                          viewModel.markSmsAsIgnored(sms.id),
                      onDelete: (sms) => viewModel.deleteSms(sms.id),
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionsSection(context, state),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context, state, viewModel),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    HomeState state,
    HomeViewModel viewModel,
  ) {
    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 80,
      toolbarHeight: 70,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Upence',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: MonthSelector(
            selectedMonth: state.selectedMonth,
            onPrevious: viewModel.previousMonth,
            onNext: viewModel.nextMonth,
            canGoNext:
                state.selectedMonth.year < DateTime.now().year ||
                state.selectedMonth.month < DateTime.now().month,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(BuildContext context, HomeState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (state.recentTransactions.length >= 10)
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.recentTransactions.isEmpty)
          _buildEmptyState(context)
        else
          ...state.recentTransactions.map(
            (ct) => TransactionListItem(compositeTransaction: ct),
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first transaction to get started',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(
    BuildContext context,
    HomeState state,
    HomeViewModel viewModel,
  ) {
    if (!state.isLoaded) {
      return FloatingActionButton.extended(
        onPressed: null,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: const Text('Loading...'),
      );
    }

    final hasAccounts = state.accounts.isNotEmpty;
    return FloatingActionButton.extended(
      onPressed: hasAccounts
          ? () => _showAddTransaction(viewModel)
          : () => _showNoAccountsError(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Transaction'),
    );
  }

  void _showNoAccountsError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please add a bank account first'),
        action: SnackBarAction(label: 'Accounts', onPressed: () {}),
      ),
    );
  }

  void _showAddTransaction(HomeViewModel viewModel) {
    final state = ref.read(homeViewModelProvider);

    AddTransactionSheet.show(
      context: context,
      categories: state.categories,
      accounts: state.accounts,
      tags: state.tags,
      onSave: (transaction, tagIds) {
        viewModel.addTransaction(transaction, tagIds: tagIds);
      },
    );
  }

  void _showAddTransactionFromSms(Sms sms) {
    final state = ref.read(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    if (state.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add a bank account first'),
          action: SnackBarAction(label: 'Accounts', onPressed: () {}),
        ),
      );
      return;
    }

    AddTransactionSheet.show(
      context: context,
      categories: state.categories,
      accounts: state.accounts,
      tags: state.tags,
      prefillSms: sms,
      onSave: (transaction, tagIds) {
        viewModel.createTransactionFromSms(sms, transaction, tagIds: tagIds);
      },
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
