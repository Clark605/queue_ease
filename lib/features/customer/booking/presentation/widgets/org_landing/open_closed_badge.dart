import 'package:flutter/material.dart';

class OpenClosedBadge extends StatelessWidget {
  const OpenClosedBadge({super.key, required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final bgColor = isOpen ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final borderColor = isOpen
        ? const Color(0xFFA7F3D0)
        : const Color(0xFFFECACA);
    final iconColor = isOpen
        ? const Color(0xFF065F46)
        : const Color(0xFF991B1B);
    final label = isOpen ? 'Open Now' : 'Closed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
