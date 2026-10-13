import 'package:flutter/material.dart';

/// Asks the user to confirm an action that can't be undone. Resolves to
/// `true` only when they tap [confirmLabel]; cancelling or dismissing the
/// dialog resolves to `false`.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
