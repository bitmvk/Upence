import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final Map<Permission, PermissionStatus> _permissionStatuses = {};

  Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    _permissionStatuses[permission] = status;
    return status.isGranted;
  }

  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    _permissionStatuses[permission] = status;
    return status.isGranted;
  }

  Future<bool> checkAllPermissions() async {
    final permissions = _getRequiredPermissions();
    final results = await Future.wait(
      permissions.map((p) => checkPermission(p)),
    );
    return results.every((granted) => granted);
  }

  Future<bool> requestAllPermissions() async {
    final permissions = _getRequiredPermissions();
    final results = await Future.wait(
      permissions.map((p) => requestPermission(p)),
    );
    return results.every((granted) => granted);
  }

  bool shouldShowRationale(Permission permission) {
    return _permissionStatuses[permission]?.isPermanentlyDenied == false;
  }

  Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  Future<void> openAppSettings() async {
    // Using the global openAppSettings from permission_handler
    // Note: This opens the app settings page
  }

  List<Permission> _getRequiredPermissions() {
    return [Permission.sms, Permission.notification];
  }

  List<Permission> getRequiredPermissions() {
    return _getRequiredPermissions();
  }

  PermissionStatus? getPermissionStatus(Permission permission) {
    return _permissionStatuses[permission];
  }
}
