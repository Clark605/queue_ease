import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Break-time configuration row embedded in a [DayWorkingHoursTile].
///
/// Shows an enable/disable Switch. When enabled, two time pickers let the
/// admin set the break window. Toggling off calls [onChanged] with nulls,
/// which clears the break on the parent entity.
class BreakTimeSection extends StatefulWidget {
  const BreakTimeSection({
    super.key,
    required this.breakStart,
    required this.breakEnd,
    required this.onChanged,
  });

  /// `null` means no break configured for this day.
  final String? breakStart;
  final String? breakEnd;
  final void Function(String? breakStart, String? breakEnd) onChanged;

  @override
  State<BreakTimeSection> createState() => _BreakTimeSectionState();
}

class _BreakTimeSectionState extends State<BreakTimeSection> {
  static const _defaultStart = '12:00';
  static const _defaultEnd = '13:00';

  bool get _enabled => widget.breakStart != null;

  TimeOfDay _parse(String hhmm) {
    final p = hhmm.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _display(String hhmm) {
    final t = _parse(hhmm);
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  Future<void> _pickTime(String current, ValueChanged<String> onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parse(current),
    );
    if (picked != null) onPicked(_fmt(picked));
  }

  void _onToggle(bool value) {
    if (value) {
      widget.onChanged(_defaultStart, _defaultEnd);
    } else {
      widget.onChanged(null, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),

      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            _BreakHeader(enabled: _enabled, onToggle: _onToggle),
            if (_enabled)
              _BreakTimeRow(
                startTime: _display(widget.breakStart!),
                endTime: _display(widget.breakEnd ?? _defaultEnd),
                onStartTap: () => _pickTime(
                  widget.breakStart!,
                  (t) => widget.onChanged(t, widget.breakEnd),
                ),
                onEndTap: () => _pickTime(
                  widget.breakEnd ?? _defaultEnd,
                  (t) => widget.onChanged(widget.breakStart, t),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _BreakHeader extends StatelessWidget {
  const _BreakHeader({required this.enabled, required this.onToggle});

  final bool enabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.coffee,
            size: 16,
            color: enabled ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Break Time',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: enabled
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enabled ? 'Tap times below to adjust' : 'Add a break period',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: AppColors.primary,
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakTimeRow extends StatelessWidget {
  const _BreakTimeRow({
    required this.startTime,
    required this.endTime,
    required this.onStartTap,
    required this.onEndTap,
  });

  final String startTime;
  final String endTime;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, String time, VoidCallback onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          Expanded(child: chip('Start', startTime, onStartTap)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Expanded(child: chip('End', endTime, onEndTap)),
        ],
      ),
    );
  }
}
