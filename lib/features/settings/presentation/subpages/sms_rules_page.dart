import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/sms_rule.dart' as models;

class SMSRulesPage extends ConsumerWidget {
  const SMSRulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesService = ref.watch(smsRulesServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SMS Rules')),
      body: rulesService.getBundledRules().isEmpty
          ? const Center(child: Text('No rules available'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rulesService.getBundledRules().length,
              itemBuilder: (context, index) {
                final rule = rulesService.getBundledRules()[index];
                return _buildRuleCard(context, ref, rule);
              },
            ),
    );
  }

  Widget _buildRuleCard(
    BuildContext context,
    WidgetRef ref,
    models.SMSRule rule,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(
          rule.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rule.description),
            const SizedBox(height: 4),
            Text(
              'Pattern: ${rule.pattern}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        value: rule.enabled,
        onChanged: (value) async {
          rule.enabled = value ?? false;
          await ref.read(smsRulesServiceProvider).saveUserSelections();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${rule.name} ${rule.enabled ? 'enabled' : 'disabled'}',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
