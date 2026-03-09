import 'package:flutter/material.dart';

/// Shows a standardised delete confirmation dialog.
///
/// Returns `true` if the user confirms the deletion, `false` if they cancel
/// or dismiss the dialog.
///
/// Usage:
/// ```dart
/// final confirmed = await showDeleteConfirmationDialog(
///   context,
///   title: 'Delete Service',
///   itemName: service.name,
/// );
/// if (confirmed) { /* delete */ }
/// ```
Future<bool> showDeleteConfirmationDialog(
  BuildContext context, {
  required String title,
  required String itemName,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(
            'Are you sure you want to delete "$itemName"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
}
