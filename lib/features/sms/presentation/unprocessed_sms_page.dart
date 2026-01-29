import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sms.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_formatter.dart';
import 'sms_processing_page.dart';

class UnprocessedSMSPage extends ConsumerWidget {
  const UnprocessedSMSPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unprocessedSMSAsync = ref.watch(unprocessedSMSProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unprocessed SMS'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_all') {
                _showDeleteAllDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: unprocessedSMSAsync.when(
        data: (messages) {
          if (messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sms_failed,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No unprocessed SMS',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final sms = messages[index];
              return _buildSMSItem(context, sms, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSMSItem(BuildContext context, SMSMessage sms, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SMSProcessingPage(sms: sms),
            ),
          );
        },
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.sms, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          sms.sender,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDateTime(sms.dateTime),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sms.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteDialog(context, sms, ref),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SMSMessage sms, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete SMS'),
        content: const Text('Are you sure you want to delete this SMS?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final smsRepo = ref.read(smsRepositoryProvider);
              final deleted = await smsRepo.deleteSMS(sms.id);
              if (deleted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('SMS deleted')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete SMS')),
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

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) async {
    final smsRepo = ref.read(smsRepositoryProvider);
    final count = await smsRepo.getUnprocessedCount();

    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unprocessed SMS to delete')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All SMS'),
        content: Text(
          'Are you sure you want to delete $count unprocessed SMS?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final deleted = await smsRepo.deleteAllUnprocessedSMS();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$deleted SMS deleted')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
