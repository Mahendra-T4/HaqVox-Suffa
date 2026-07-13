import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _permissionsChecked = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissions = [Permission.notification];

    // Check if permissions are already granted
    final statuses = await Future.wait(
      permissions.map((permission) => permission.status),
    );

    if (statuses.every((status) => status.isGranted)) {
      setState(() => _permissionsChecked = true);
      return;
    }

    // Request permissions
    final results = await permissions.request();

    if (mounted) {
      setState(() => _permissionsChecked = true);
    }

    // If any permission is permanently denied, show settings dialog
    if (results.values.any((status) => status.isPermanentlyDenied)) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Permissions Required'),
                content: const Text(
                  'This app needs access to storage and notifications to function properly. '
                  'Please enable these permissions in your device settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsChecked) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking permissions...'),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
