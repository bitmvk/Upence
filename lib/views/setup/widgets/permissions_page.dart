import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upence/views/setup/setup_view_model.dart';

class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  late final AppLifecycleListener _listener;
  AppLifecycleState? _appstate;

  @override
  void initState() {
    super.initState();
    final checkPermissions = ref
        .read(setupViewModelProvider.notifier)
        .checkPermissions;
    _listener = AppLifecycleListener(
      onShow: () => checkPermissions(),
      onResume: () => checkPermissions(),
      onRestart: () => checkPermissions(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(setupViewModelProvider.notifier).checkPermissions();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _listener.dispose();
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Permissions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
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
            permissionStatus: permissions['SMS'] ?? AppPermissionStatus.denied,
            onRequest:
                permissions['SMS'] != AppPermissionStatus.permanentlyDenied
                ? () => viewModel.requestPermissions("SMS")
                : () async {
                    await openAppSettings();
                  },
          ),
          const SizedBox(height: 16),
          _PermissionItem(
            icon: Icons.notifications,
            title: 'Notifications',
            description: 'To send expense alerts and reminders',
            permissionStatus:
                permissions['Notifications'] ?? AppPermissionStatus.denied,
            onRequest:
                permissions['Notifications'] !=
                    AppPermissionStatus.permanentlyDenied
                ? () => viewModel.requestPermissions("Notification")
                : () async {
                    await openAppSettings();
                  },
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
  final AppPermissionStatus permissionStatus;
  final VoidCallback onRequest;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.permissionStatus,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    String buttonText = permissionStatus == AppPermissionStatus.checking
        ? "Loading..."
        : (permissionStatus == AppPermissionStatus.permanentlyDenied
              ? "Settings"
              : "Grant");
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: permissionStatus == AppPermissionStatus.granted
            ? Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: permissionStatus == AppPermissionStatus.checking
                    ? () {}
                    : (permissionStatus == AppPermissionStatus.permanentlyDenied
                          ? () async {
                              await openAppSettings();
                            }
                          : onRequest),
                child: Text(buttonText),
              ),
      ),
    );
  }
}
