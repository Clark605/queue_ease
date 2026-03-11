import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../shared/organization/domain/entities/working_hours_entity.dart';
import '../cubit/working_hours_state.dart';
import 'day_working_hours_tile.dart';

/// Scrollable body of the Working Hours page.
///
/// Shows a loading spinner while data is in-flight, an error view on stream
/// failure, and the editable day list with a sticky Save button otherwise.
class WorkingHoursBody extends StatelessWidget {
  const WorkingHoursBody({
    super.key,
    required this.state,
    required this.pendingDays,
    required this.onDayChanged,
    required this.onApplyMonday,
    required this.onSave,
    required this.onRetry,
  });

  final WorkingHoursState state;
  final List<WorkingHoursEntity> pendingDays;
  final ValueChanged<WorkingHoursEntity> onDayChanged;
  final VoidCallback onApplyMonday;
  final VoidCallback onSave;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state is WorkingHoursLoading || pendingDays.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state case WorkingHoursStreamError(:final message)) {
      return ErrorView(
        title: 'Failed to load working hours',
        message: message,
        onRetry: onRetry,
      );
    }

    return Column(
      children: [
        Expanded(
          child: _DayList(
            pendingDays: pendingDays,
            onDayChanged: onDayChanged,
            onApplyMonday: onApplyMonday,
          ),
        ),
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: LoadingButton(
            label: 'Save Working Hours',
            onPressed: pendingDays.isEmpty ? null : onSave,
            isLoading: state is WorkingHoursSaving,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _DayList extends StatelessWidget {
  const _DayList({
    required this.pendingDays,
    required this.onDayChanged,
    required this.onApplyMonday,
  });

  final List<WorkingHoursEntity> pendingDays;
  final ValueChanged<WorkingHoursEntity> onDayChanged;
  final VoidCallback onApplyMonday;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            'Set your business operating hours. This will determine when customers can join the queue.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        ...pendingDays.map(
          (day) => DayWorkingHoursTile(
            key: ValueKey(day.dayOfWeek),
            entity: day,
            onChanged: onDayChanged,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextButton.icon(
            onPressed: onApplyMonday,
            icon: const Icon(Icons.content_copy, size: 18),
            label: const Text("Apply Monday's hours to all weekdays"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onSurfaceVariant,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }
}
