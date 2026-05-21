import 'package:flutter/material.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    required this.onBook,
    required this.onSeeAll,
  });

  final VoidCallback onBook;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 360;
        final buttonShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        );
        final bookButton = FilledButton.icon(
          onPressed: onBook,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: buttonShape,
          ),
          icon: const Icon(Icons.add),
          label: const Text('Book Appointment'),
        );
        final seeAllButton = OutlinedButton.icon(
          onPressed: onSeeAll,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: buttonShape,
          ),
          icon: const Icon(Icons.calendar_today),
          label: const Text('See all appointments'),
        );

        if (isTight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [bookButton, const SizedBox(height: 12), seeAllButton],
          );
        }

        return Row(
          children: [
            Expanded(child: bookButton),
            const SizedBox(width: 12),
            Expanded(child: seeAllButton),
          ],
        );
      },
    );
  }
}
