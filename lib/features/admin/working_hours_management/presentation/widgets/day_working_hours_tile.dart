import 'package:flutter/material.dart';
import 'package:queue_ease/core/theme/app_colors.dart';
import 'package:queue_ease/core/theme/app_text_styles.dart';
import 'package:queue_ease/core/utils/time_picker_helper.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';

import 'break_time_section.dart';

/// A tile representing one day's working hours configuration.
///
/// Shows the day name with an open/closed switch. When open, two time
/// pickers let the admin set openTime and closeTime. Includes break
/// time configuration via [BreakTimeSection].
class DayWorkingHoursTile extends StatefulWidget {
  const DayWorkingHoursTile({
    super.key,
    required this.entity,
    required this.onChanged,
  });

  final WorkingHoursEntity entity;
  final ValueChanged<WorkingHoursEntity> onChanged;

  @override
  State<DayWorkingHoursTile> createState() => _DayWorkingHoursTileState();
}

class _DayWorkingHoursTileState extends State<DayWorkingHoursTile> {
  bool _isExpanded = false;

  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  WorkingHoursEntity get _e => widget.entity;

  String get _dayName => _dayNames[_e.dayOfWeek.clamp(0, 6)];

  /// Returns a copy of the current entity with the specified fields overridden.
  ///
  /// Pass [clearBreaks] to explicitly null out break fields (e.g. on toggle-off).
  WorkingHoursEntity _clone({
    bool? isOpen,
    String? openTime,
    String? closeTime,
    String? breakStart,
    String? breakEnd,
    bool clearBreaks = false,
  }) => WorkingHoursEntity(
    orgId: _e.orgId,
    dayOfWeek: _e.dayOfWeek,
    isOpen: isOpen ?? _e.isOpen,
    openTime: openTime ?? _e.openTime,
    closeTime: closeTime ?? _e.closeTime,
    breakStart: clearBreaks ? null : (breakStart ?? _e.breakStart),
    breakEnd: clearBreaks ? null : (breakEnd ?? _e.breakEnd),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _e.isOpen ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _e.isOpen
              ? const Color(0xFFE5E7EB)
              : AppColors.outline.withValues(alpha: 0.4),
        ),
        boxShadow: _e.isOpen
            ? const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          _DayHeader(
            dayName: _dayName,
            isOpen: _e.isOpen,
            isExpanded: _isExpanded,
            breakStart: _e.breakStart,
            breakEnd: _e.breakEnd,
            onToggle: (v) {
              setState(() => _isExpanded = v);
              widget.onChanged(_clone(isOpen: v, clearBreaks: !v));
            },
            onExpand: () => setState(() => _isExpanded = !_isExpanded),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _e.isOpen && _isExpanded
                ? Column(
                    children: [
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _TimeRow(
                        openTime: TimePickerHelper.display(_e.openTime),
                        closeTime: TimePickerHelper.display(_e.closeTime),
                        onOpenTap: () async {
                          final picked = await TimePickerHelper.pick(
                            context,
                            _e.openTime,
                          );
                          if (picked != null) {
                            widget.onChanged(
                              _clone(openTime: TimePickerHelper.format(picked)),
                            );
                          }
                        },
                        onCloseTap: () async {
                          final picked = await TimePickerHelper.pick(
                            context,
                            _e.closeTime,
                          );
                          if (picked != null) {
                            widget.onChanged(
                              _clone(
                                closeTime: TimePickerHelper.format(picked),
                              ),
                            );
                          }
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      BreakTimeSection(
                        breakStart: _e.breakStart,
                        breakEnd: _e.breakEnd,
                        onChanged: (s, e) => widget.onChanged(
                          _clone(
                            breakStart: s,
                            breakEnd: e,
                            clearBreaks: s == null,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.dayName,
    required this.isOpen,
    required this.isExpanded,
    required this.breakStart,
    required this.breakEnd,
    required this.onToggle,
    required this.onExpand,
  });

  final String dayName;
  final bool isOpen;
  final bool isExpanded;
  final String? breakStart;
  final String? breakEnd;
  final ValueChanged<bool> onToggle;
  final VoidCallback onExpand;

  String get _subtitle {
    if (!isOpen) return 'Closed';
    if (breakStart != null && breakEnd != null) {
      return 'Open · Break ${TimePickerHelper.display(breakStart!)}–${TimePickerHelper.display(breakEnd!)}';
    }
    return 'Open';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isOpen ? onExpand : null,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isOpen
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isOpen
                          ? AppColors.success
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isOpen)
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            Switch(
              value: isOpen,
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
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.openTime,
    required this.closeTime,
    required this.onOpenTap,
    required this.onCloseTap,
  });

  final String openTime;
  final String closeTime;
  final VoidCallback onOpenTap;
  final VoidCallback onCloseTap;

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Expanded(child: chip('Opens', openTime, onOpenTap)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Expanded(child: chip('Closes', closeTime, onCloseTap)),
        ],
      ),
    );
  }
}
