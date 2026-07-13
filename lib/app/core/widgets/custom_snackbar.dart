import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:haqvox/app/constant/constant.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Use addPostFrameCallback to ensure the widget tree is stable
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Check if context is still valid before showing snackbar
      if (!context.mounted) return;

      try {
        final snackBar = SnackBar(
          content: Row(
            children: [
              _getIcon(type),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: white14RegularTextStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: _getBackgroundColor(type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: const EdgeInsets.all(16),
          duration: duration,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      } catch (e) {
        debugPrint('Error showing snackbar: $e');
      }
    });
  }

  static Widget _getIcon(SnackBarType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case SnackBarType.success:
        iconData = Icons.check_circle_outline;
        iconColor = Colors.white;
        break;
      case SnackBarType.error:
        iconData = Icons.error_outline;
        iconColor = Colors.white;
        break;
      case SnackBarType.warning:
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.white;
        break;
      case SnackBarType.info:
        iconData = Icons.info_outline;
        iconColor = Colors.white;
        break;
    }

    return Icon(iconData, color: iconColor, size: 24);
  }

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return greenColor;
      case SnackBarType.error:
        return redColor;
      case SnackBarType.warning:
        return yellowColor.withOpacity(0.9);
      case SnackBarType.info:
        return primaryColor;
    }
  }
}

enum SnackBarType { success, error, warning, info }
