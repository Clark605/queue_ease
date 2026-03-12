import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';

/// Displays available time slots grouped by Morning / Afternoon / Evening.
///
/// Slots are rendered in a 3-column grid. [selectedSlot] is highlighted with
/// a solid primary fill; unselected slots use an outlined primary style.
/// Tapping a slot fires [onSlotSelected].
class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  final List<DateTime> slots;
  final DateTime? selectedSlot;
  final void Function(DateTime) onSlotSelected;

  @override
  Widget build(BuildContext context) {
    final morning = slots.where((s) => s.hour < 12).toList();
    final afternoon = slots.where((s) => s.hour >= 12 && s.hour < 17).toList();
    final evening = slots.where((s) => s.hour >= 17).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morning.isNotEmpty) ...[
          _SlotSection(
            title: 'Morning',
            slots: morning,
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
          const SizedBox(height: 24),
        ],
        if (afternoon.isNotEmpty) ...[
          _SlotSection(
            title: 'Afternoon',
            slots: afternoon,
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
          const SizedBox(height: 24),
        ],
        if (evening.isNotEmpty)
          _SlotSection(
            title: 'Evening',
            slots: evening,
            selectedSlot: selectedSlot,
            onSlotSelected: onSlotSelected,
          ),
      ],
    );
  }
}

class _SlotSection extends StatelessWidget {
  const _SlotSection({
    required this.title,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  final String title;
  final List<DateTime> slots;
  final DateTime? selectedSlot;
  final void Function(DateTime) onSlotSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${slots.length} slot${slots.length == 1 ? '' : 's'} available',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 44,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: slots.length,
          itemBuilder: (context, i) {
            final slot = slots[i];
            final isSelected =
                selectedSlot != null &&
                slot.year == selectedSlot!.year &&
                slot.month == selectedSlot!.month &&
                slot.day == selectedSlot!.day &&
                slot.hour == selectedSlot!.hour &&
                slot.minute == selectedSlot!.minute;
            return _SlotChip(
              slot: slot,
              isSelected: isSelected,
              onTap: () => onSlotSelected(slot),
            );
          },
        ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('hh:mm a').format(slot);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
