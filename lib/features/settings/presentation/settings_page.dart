import 'package:flutter/material.dart' hide AboutDialog;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/page_wrapper.dart';
import 'subpages/category_management_page.dart';
import 'subpages/tag_management_page.dart';
import 'subpages/pattern_management_page.dart';
import 'widgets/about_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final currencyAsync = ref.watch(currencyProvider);

    return PageWrapper(
      title: const Text('Settings'),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          themeModeAsync.when(
            data: (themeMode) => _buildThemeTile(context, ref, themeMode),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => const Text('Error loading theme'),
          ),
          _buildSectionHeader('Preferences'),
          currencyAsync.when(
            data: (currency) => _buildCurrencyTile(context, ref, currency),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => const Text('Error loading currency'),
          ),
          _buildSectionHeader('Data Management'),
          _buildDataTile(
            context,
            icon: Icons.category,
            title: 'Categories',
            subtitle: 'Manage transaction categories',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementPage(),
                ),
              );
            },
          ),
          _buildDataTile(
            context,
            icon: Icons.account_balance,
            title: 'Bank Accounts',
            subtitle: 'Manage your bank accounts',
            onTap: () {
              Navigator.pushNamed(context, '/accounts', arguments: true);
            },
          ),
          _buildDataTile(
            context,
            icon: Icons.label,
            title: 'Tags',
            subtitle: 'Manage transaction tags',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TagManagementPage(),
                ),
              );
            },
          ),
          _buildDataTile(
            context,
            icon: Icons.pattern,
            title: 'SMS Patterns',
            subtitle: 'Manage SMS parsing patterns',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatternManagementPage(),
                ),
              );
            },
          ),
          _buildDataTile(
            context,
            icon: Icons.block,
            title: 'Ignored Senders',
            subtitle: 'Manage ignored SMS senders',
            onTap: () {
              Navigator.pushNamed(context, '/settings/ignored-senders');
            },
          ),
          _buildSectionHeader('Data'),
          _buildDataTile(
            context,
            icon: Icons.upload_file,
            title: 'Export Data',
            subtitle: 'Export all data to JSON',
            onTap: () {
              // TODO: Implement export
            },
          ),
          _buildDataTile(
            context,
            icon: Icons.file_download,
            title: 'Import Data',
            subtitle: 'Import data from JSON',
            onTap: () {
              // TODO: Implement import
            },
          ),
          _buildDataTile(
            context,
            icon: Icons.refresh,
            title: 'Reset Data',
            subtitle: 'Delete all data and reset app',
            onTap: () {
              _showResetDialog(context, ref);
            },
          ),
          _buildSectionHeader('About'),
          _buildDataTile(
            context,
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Theme'),
      subtitle: Text(_getThemeModeText(currentMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, ref, currentMode),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                _saveThemeMode(ref, ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                _saveThemeMode(ref, ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                _saveThemeMode(ref, ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveThemeMode(WidgetRef ref, ThemeMode mode) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final modeString = mode.toString().split('.').last;
    await prefs.setString('theme_mode', modeString);
    ref.invalidate(themeModeProvider);
  }

  Widget _buildCurrencyTile(
    BuildContext context,
    WidgetRef ref,
    String currentCurrency,
  ) {
    return ListTile(
      leading: const Icon(Icons.currency_exchange),
      title: const Text('Currency'),
      subtitle: Text(currentCurrency),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCurrencyDialog(context, ref, currentCurrency),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    WidgetRef ref,
    String currentCurrency,
  ) {
    final currencies = ['₹ ruppee', '\$ dollar', '€ euro', '£ pound', '¥ yen'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: currentCurrency,
              onChanged: (value) {
                _saveCurrency(ref, value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _saveCurrency(WidgetRef ref, String currency) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString('currency', currency);
    ref.invalidate(currencyProvider);
  }

  Widget _buildDataTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
          'This will delete all your data including transactions, categories, accounts, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement reset
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data reset successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AboutDialog());
  }
}
