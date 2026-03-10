import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';
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
      return _ErrorView(message: message, onRetry: onRetry);
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
        _SaveButton(
          onSave: pendingDays.isEmpty ? null : onSave,
          isSaving: state is WorkingHoursSaving,
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

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onSave, required this.isSaving});

  final VoidCallback? onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: isSaving ? null : onSave,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isSaving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Save Working Hours',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load working hours',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
