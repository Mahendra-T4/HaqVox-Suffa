import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';


class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onConfirm;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Confirm',
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              color: primaryColor,
              elevation: 0,
              highlightElevation: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text(
                  buttonText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>CustomAlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onConfirm: onConfirm,
      ),
    );
  }
}
