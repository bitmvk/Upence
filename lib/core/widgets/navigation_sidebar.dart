import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavItem { home, accounts, analytics, settings }

class NavigationSidebar extends ConsumerStatefulWidget {
  final NavItem selectedItem;
  final Function(NavItem) onItemSelected;

  const NavigationSidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  ConsumerState<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends ConsumerState<NavigationSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
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
        child: Column(
          children: [
            _buildHeader(),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    item: NavItem.home,
                  ),
                  _buildNavItem(
                    icon: Icons.account_balance_wallet,
                    label: 'Accounts',
                    item: NavItem.accounts,
                  ),
                  _buildNavItem(
                    icon: Icons.bar_chart,
                    label: 'Analytics',
                    item: NavItem.analytics,
                  ),
                  _buildNavItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    item: NavItem.settings,
                  ),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 12,
                      ),
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
    required IconData icon,
    required String label,
    required NavItem item,
  }) {
    final isSelected = widget.selectedItem == item;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      onTap: () {
        widget.onItemSelected(item);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildFooter() {
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

  void open() {
    _animationController.forward();
  }

  void close() {
    _animationController.reverse();
  }
}
