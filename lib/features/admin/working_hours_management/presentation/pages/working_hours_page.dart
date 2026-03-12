import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_snack_bar.dart';
import '../../../../../features/authentication/presentation/cubit/auth_cubit.dart';
import '../../../../../features/authentication/presentation/cubit/auth_state.dart';
import '../../../../../features/shared_domain/entities/working_hours_entity.dart';
import '../cubit/working_hours_cubit.dart';
import '../cubit/working_hours_state.dart';
import '../widgets/working_hours_app_bar.dart';
import '../widgets/working_hours_body.dart';

/// Working hours configuration page.
///
/// Streams the current schedule, lets the admin edit each day inline,
/// and persists the full week on "Save".
///
/// Stitch reference: screen 30a66cbc56df4c09a3d8a997c8a0aa6c
class WorkingHoursPage extends StatefulWidget {
  const WorkingHoursPage({super.key});

  @override
  State<WorkingHoursPage> createState() => _WorkingHoursPageState();
}

class _WorkingHoursPageState extends State<WorkingHoursPage> {
  late final String _orgId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthCubit>().state;
    _orgId = auth is Authenticated ? (auth.user.organizationId ?? '') : '';
    if (_orgId.isNotEmpty) {
      context.read<WorkingHoursCubit>().watchWorkingHours(_orgId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkingHoursCubit, WorkingHoursState>(
      buildWhen: (_, curr) =>
          curr is WorkingHoursInitial ||
          curr is WorkingHoursLoading ||
          curr is WorkingHoursLoaded ||
          curr is WorkingHoursStreamError,
      listener: _handleState,
      builder: (context, state) {
        final pendingDays = state is WorkingHoursLoaded
            ? state.pendingDays
            : const <WorkingHoursEntity>[];
        final cubit = context.read<WorkingHoursCubit>();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const WorkingHoursAppBar(),
          body: WorkingHoursBody(
            state: state,
            pendingDays: pendingDays,
            onDayChanged: cubit.updateDay,
            onApplyMonday: cubit.applyMondayToWeekdays,
            onSave: () => cubit.saveAll(orgId: _orgId, days: pendingDays),
            onRetry: () => cubit.watchWorkingHours(_orgId),
          ),
        );
      },
    );
  }

  void _handleState(BuildContext context, WorkingHoursState state) {
    switch (state) {
      case WorkingHoursSaveSuccess():
        AppSnackBar.showSuccess(context, 'Working hours saved');
      case WorkingHoursSaveError(:final message):
        AppSnackBar.showError(context, message);
      case _:
        break;
    }
  }
}
