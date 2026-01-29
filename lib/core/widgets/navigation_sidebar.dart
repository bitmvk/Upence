import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavItem { home, accounts, analytics, settings }

class NavigationSidebar extends ConsumerWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Builder(
          builder: (drawerContext) => Column(
            children: [
              _buildHeader(drawerContext),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildNavItem(
                      context: drawerContext,
                      ref: ref,
                      icon: Icons.home,
                      label: 'Home',
                    ),
                    _buildNavItem(
                      context: drawerContext,
                      ref: ref,
                      icon: Icons.account_balance_wallet,
                      label: 'Accounts',
                    ),
                    _buildNavItem(
                      context: drawerContext,
                      ref: ref,
                      icon: Icons.bar_chart,
                      label: 'Analytics',
                    ),
                    _buildNavItem(
                      context: drawerContext,
                      ref: ref,
                      icon: Icons.settings,
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
              _buildFooter(drawerContext),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upence',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SMS Transaction Tracker',
                      style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      onTap: () {
        final scaffold = Scaffold.of(context);
        scaffold.closeDrawer();
        final navigator = Navigator.of(context);
        switch (label) {
          case 'Home':
            navigator.pushNamed('/');
            break;
          case 'Accounts':
            navigator.pushNamed('/accounts');
            break;
          case 'Analytics':
            navigator.pushNamed('/analytics');
            break;
          case 'Settings':
            navigator.pushNamed('/settings');
            break;
        }
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Column(
        children: [
          const Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'Made with ❤️ in India',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
