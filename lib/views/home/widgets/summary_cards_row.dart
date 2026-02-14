import 'package:flutter/material.dart';
import 'package:upence/core/utils/formatters.dart';

class SummaryCardsRow extends StatelessWidget {
  final int totalIncome;
  final int totalExpense;
  final int netSpend;
  final bool isLoading;

  const SummaryCardsRow({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSpend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildNetSpendCard(context),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Income',
                amount: totalIncome,
                icon: Icons.trending_up_rounded,
                color: colorScheme.tertiary,
                isIncome: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Expense',
                amount: totalExpense,
                icon: Icons.trending_down_rounded,
                color: colorScheme.error,
                isIncome: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetSpendCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPositive = netSpend >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPositive
              ? [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withValues(alpha: 0.7),
                ]
              : [
                  colorScheme.errorContainer,
                  colorScheme.errorContainer.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.savings_rounded
                    : Icons.trending_down_rounded,
                color: isPositive
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Net Spend',
                style: textTheme.titleMedium?.copyWith(
                  color: isPositive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatAbs(netSpend),
            style: textTheme.headlineMedium?.copyWith(
              color: isPositive
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPositive
                ? 'You saved money this month!'
                : 'Expenses exceeded income',
            style: textTheme.bodySmall?.copyWith(
              color: isPositive
                  ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                  : colorScheme.onErrorContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required int amount,
    required IconData icon,
    required Color color,
    required bool isIncome,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Icon(
                isIncome ? Icons.add_rounded : Icons.remove_rounded,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatAbs(amount),
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
