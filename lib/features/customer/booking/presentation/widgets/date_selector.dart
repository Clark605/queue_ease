import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';

/// Horizontal 7-day date selector (today + 6 days).
///
/// Displays a scrollable row of date tiles. Days in [closedDayIndices]
/// (0=Mon … 6=Sun) are shown as disabled. Tapping an available date fires
/// [onDateSelected].
class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.closedDayIndices,
    required this.onDateSelected,
  });

  final DateTime selectedDate;

  /// Weekday indices (0=Mon … 6=Sun) that are closed / unavailable.
  final Set<int> closedDayIndices;
  final void Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + i),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            DateFormat('MMMM yyyy').format(selectedDate),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final day = days[i];
              // DateTime.weekday: 1=Mon…7=Sun → 0-based index: 0=Mon…6=Sun
              final dayIndex = day.weekday - 1;
              final isClosed = closedDayIndices.contains(dayIndex);
              final isSelected =
                  day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;
              return _DateTile(
                date: day,
                isSelected: isSelected,
                isClosed: isClosed,
                onTap: isClosed ? null : () => onDateSelected(day),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.date,
    required this.isSelected,
    required this.isClosed,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isClosed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return _tile(
        background: AppColors.primary,
        border: AppColors.primary,
        dayLabelColor: Colors.white.withValues(alpha: 0.85),
        dayNumColor: Colors.white,
        elevation: 4,
      );
    }
    if (isClosed) {
      return Opacity(
        opacity: 0.4,
        child: _tile(
          background: Colors.grey.shade100,
          border: Colors.transparent,
          dayLabelColor: Colors.grey,
          dayNumColor: Colors.grey,
        ),
      );
    }
    return _tile(
      background: Theme.of(context).colorScheme.surface,
      border: Theme.of(context).colorScheme.outlineVariant,
      dayLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      dayNumColor: Theme.of(context).colorScheme.onSurface,
      onTap: onTap,
    );
  }

  Widget _tile({
    required Color background,
    required Color border,
    required Color dayLabelColor,
    required Color dayNumColor,
    double elevation = 0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 72,
        height: 80,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(date).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: dayLabelColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: dayNumColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
