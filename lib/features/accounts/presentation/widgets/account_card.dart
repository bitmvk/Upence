import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/bank_account.dart';
import '../../../../data/models/account_analytics.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';

class AccountCard extends ConsumerStatefulWidget {
  final BankAccount account;
  final VoidCallback? onMenuTap;

  const AccountCard({super.key, required this.account, this.onMenuTap});

  @override
  ConsumerState<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<AccountCard> {
  bool _showFullAccountNumber = false;

  void _toggleAccountNumber() {
    setState(() {
      _showFullAccountNumber = !_showFullAccountNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountId = widget.account.id.toString();
    final analyticsAsync = ref.watch(accountAnalyticsProvider(accountId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    _getIcon(widget.account.icon),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.accountName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getAccountNumberDisplay(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          if (widget.account.accountNumber.isNotEmpty &&
                              widget.account.accountNumber.length > 4)
                            IconButton(
                              icon: Icon(
                                _showFullAccountNumber
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 16,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _toggleAccountNumber,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: widget.onMenuTap,
                ),
              ],
            ),
            analyticsAsync.when(
              data: (analytics) => _buildAnalytics(context, analytics),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => const Text('Error loading analytics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalytics(BuildContext context, AccountAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBalanceRow(context, analytics.balance),
        const SizedBox(height: 8),
        _buildStatRow(
          context,
          icon: Icons.bar_chart,
          label: 'Transactions',
          value: analytics.transactionCount.toString(),
        ),
        const SizedBox(height: 4),
        _buildStatRow(
          context,
          icon: Icons.arrow_downward,
          label: 'Avg/mo (income)',
          value: '₹${analytics.avgMonthlyIncome.toStringAsFixed(2)}',
          color: AppColors.income,
        ),
        const SizedBox(height: 4),
        _buildStatRow(
          context,
          icon: Icons.arrow_upward,
          label: 'Avg/mo (expense)',
          value: '₹${analytics.avgMonthlyExpense.toStringAsFixed(2)}',
          color: AppColors.expense,
        ),
        if (analytics.lastTransactionDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Last: ${DateFormatter.formatRelative(analytics.lastTransactionDate!)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBalanceRow(BuildContext context, double balance) {
    final isPositive = balance >= 0;
    return Row(
      children: [
        Icon(Icons.account_balance_wallet, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          'Balance: ₹${balance.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isPositive ? AppColors.income : AppColors.expense,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 13,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getAccountNumberDisplay() {
    if (widget.account.accountNumber.isEmpty) return 'Account';
    if (_showFullAccountNumber) return widget.account.accountNumber;

    final number = widget.account.accountNumber;
    final parts = <String>[];
    for (int i = 0; i < number.length; i += 4) {
      final end = (i + 4 < number.length) ? i + 4 : number.length;
      final chunk = number.substring(i, end);
      parts.add(chunk);
    }

    return parts
        .map((part) {
          if (part == parts.last) return part;
          return '••••';
        })
        .join(' ');
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
