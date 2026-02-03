import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upence/views/setup/setup_view_model.dart';

class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(setupViewModelProvider.notifier).checkPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(
      setupViewModelProvider.select((state) => state.permissionsGranted),
    );
    final viewModel = ref.read(setupViewModelProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text('Permissions', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(
            'Upence needs these permissions to work properly.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          _PermissionItem(
            icon: Icons.sms,
            title: 'SMS Access',
            description: 'To read and parse transaction SMS messages',
            isGranted: permissions['SMS'] ?? false,
            onRequest: () => viewModel.requestPermissions(),
          ),
          const SizedBox(height: 16),
          _PermissionItem(
            icon: Icons.notifications,
            title: 'Notifications',
            description: 'To send expense alerts and reminders',
            isGranted: permissions['Notifications'] ?? false,
            onRequest: () => viewModel.requestPermissions(),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onRequest;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: isGranted
            ? Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(onPressed: onRequest, child: const Text('Grant')),
      ),
    );
  }
}
