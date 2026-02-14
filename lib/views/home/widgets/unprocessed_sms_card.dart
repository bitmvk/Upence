import 'package:flutter/material.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/views/home/widgets/sms_list_item.dart';

class UnprocessedSmsCard extends StatelessWidget {
  final List<Sms> smsList;
  final bool isLoading;
  final void Function(Sms) onCreateTransaction;
  final void Function(Sms) onMarkAsNotTransaction;
  final void Function(Sms) onDelete;

  const UnprocessedSmsCard({
    super.key,
    required this.smsList,
    this.isLoading = false,
    required this.onCreateTransaction,
    required this.onMarkAsNotTransaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (smsList.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: smsList
                    .map(
                      (sms) => SmsListItem(
                        sms: sms,
                        onCreateTransaction: () => onCreateTransaction(sms),
                        onMarkAsNotTransaction: () =>
                            onMarkAsNotTransaction(sms),
                        onDelete: () => onDelete(sms),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.mark_email_unread_rounded,
              size: 20,
              color: colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unprocessed Messages',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review and create transactions from these SMS',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${smsList.length}',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onError,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
