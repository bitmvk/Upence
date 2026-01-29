import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/sender.dart';
import '../../../../core/utils/date_formatter.dart';

class IgnoredSendersPage extends ConsumerWidget {
  const IgnoredSendersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ignoredSendersAsync = ref.watch(ignoredSendersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ignored Senders'),
      ),
      body: ignoredSendersAsync.when(
        data: (senders) {
          if (senders.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => _refreshData(ref),
            child: ListView.builder(
              itemCount: senders.length,
              itemBuilder: (context, index) {
                final sender = senders[index];
                return _buildSenderCard(context, ref, sender);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ignored senders',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Senders that you ignore will appear here',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderCard(
    BuildContext context,
    WidgetRef ref,
    Sender sender,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.block,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        title: Text(
          sender.senderName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (sender.accountId.isNotEmpty)
              Text(
                'Account: ${sender.accountId}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            if (sender.ignoreReason != null && sender.ignoreReason!.isNotEmpty)
              Text(
                'Reason: ${sender.ignoreReason}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            if (sender.ignoredAt != null)
              Text(
                'Ignored: ${DateFormatter.formatDate(DateTime.fromMillisecondsSinceEpoch(sender.ignoredAt!))}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
        trailing: TextButton.icon(
          onPressed: () => _showUnignoreDialog(context, ref, sender),
          icon: const Icon(Icons.undo),
          label: const Text('Unignore'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _showUnignoreDialog(
    BuildContext context,
    WidgetRef ref,
    Sender sender,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unignore Sender'),
        content: Text(
          'Are you sure you want to stop ignoring messages from "${sender.senderName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final repo = ref.read(senderRepositoryProvider);
              await repo.unmarkAsIgnored(sender.senderName);
              ref.invalidate(ignoredSendersProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${sender.senderName} unignored successfully'),
                  ),
                );
              }
            },
            child: const Text('Unignore'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(ignoredSendersProvider);
  }
}
