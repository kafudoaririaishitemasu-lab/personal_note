import 'package:flutter/material.dart';
import '../../config/app_pallete.dart';

class UiSnack {
  static void showInfoSnackBar(BuildContext context, {
    IconData? icon,
    required String message,
    Color color = primaryColor,
    bool isError = false,
    Duration duration = const Duration(seconds: 1),
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? errorColor : color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration,
        content: Row(
          children: [
            icon != null
                ? Icon(icon, color: Colors.white)
                : const SizedBox(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showNetworkErrorSnackBar(
      BuildContext context, {
        String message = "Network connection failed.",
        Color? color,
        required bool isNetworkError,
        Duration duration = const Duration(seconds: 3),
      }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isNetworkError ? Icons.wifi_off : Icons.wifi, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isNetworkError ? Colors.red.shade700 : Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}