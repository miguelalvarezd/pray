import 'package:flutter/material.dart';

/// Shows a short confirmation of a reversible change, with an Undo action.
/// Used instead of a confirmation dialog for changes like archiving.
void showUndoSnackBar(
  BuildContext context,
  String message, {
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Undo', onPressed: onUndo),
      ),
    );
}
