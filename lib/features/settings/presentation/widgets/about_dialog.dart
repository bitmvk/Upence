import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:upence/core/constants/app_constants.dart';

class AboutDialog extends StatelessWidget {
  const AboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final version = AppConstants.appVersion;

    return AlertDialog(
      title: Column(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.appName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'v$version',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 14,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              AppConstants.appDescription.trim(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text('Links', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildLinkTile(
              context,
              icon: Icons.code,
              title: 'GitHub',
              url: AppConstants.githubUrl,
            ),
            _buildLinkTile(
              context,
              icon: Icons.description,
              title: AppConstants.licenseName,
              url: AppConstants.licenseUrl,
            ),
            _buildLinkTile(
              context,
              icon: Icons.email,
              title: AppConstants.supportEmail,
              url: 'mailto:${AppConstants.supportEmail}',
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _launchUrl(AppConstants.bugReportUrl),
          icon: const Icon(Icons.bug_report),
          label: const Text('Report Bug'),
        ),
        TextButton.icon(
          onPressed: () => _launchUrl(AppConstants.feedbackUrl),
          icon: const Icon(Icons.feedback),
          label: const Text('Feedback'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
