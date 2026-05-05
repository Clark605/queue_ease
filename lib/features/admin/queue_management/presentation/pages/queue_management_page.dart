import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:queue_ease/core/theme/app_colors.dart';
import 'package:queue_ease/core/theme/app_text_styles.dart';
import 'package:queue_ease/core/utils/app_snack_bar.dart';
import 'package:queue_ease/core/widgets/widgets.dart';
import 'package:queue_ease/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:queue_ease/features/authentication/presentation/cubit/auth_state.dart';

import '../cubit/queue_management_cubit.dart';
import '../cubit/queue_management_state.dart';
import '../widgets/queue_content.dart';

/// The live admin queue management screen.
///
/// Wires [QueueManagementCubit] (provided by AdminMainPage) to the UI.
/// Renders the currently-serving card, the waiting list, and a summary bar.
/// Action errors are surfaced as snackbars; initial load errors show a
/// full-screen error view with a retry button.
class QueueManagementPage extends StatelessWidget {
  const QueueManagementPage({super.key});

  /// Extracts the authenticated admin's organisation ID from [AuthCubit].
  /// Returns an empty string if the auth state is not [Authenticated].
  String _getOrgId(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated && authState.user.organizationId != null) {
      return authState.user.organizationId!;
    }
    return '';
  }

  Future<void> _pickDate({
    required BuildContext context,
    required String orgId,
    required DateTime selectedDate,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    context.read<QueueManagementCubit>().watchQueue(
      orgId: orgId,
      date: pickedDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthCubit>().state is Authenticated;
    final selectedDate = context.select(
      (QueueManagementCubit cubit) => cubit.selectedDate,
    );

    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    final orgId = _getOrgId(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Queue Management',
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('MMM d, y').format(selectedDate),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Select date',
            onPressed: () => _pickDate(
              context: context,
              orgId: orgId,
              selectedDate: selectedDate,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add_check_rounded),
            color: AppColors.primary,
            tooltip: 'Generate queue for selected date',
            onPressed: () => context.read<QueueManagementCubit>().generateQueue(
              orgId: orgId,
              date: selectedDate,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Filter',
            onPressed: () =>
                AppSnackBar.showInfo(context, 'Filter - Coming soon'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.outline.withValues(alpha: 0.4),
            height: 1,
          ),
        ),
      ),
      body: BlocConsumer<QueueManagementCubit, QueueManagementState>(
        // Only show the snackbar for errors that fire while queue content is
        // already visible — i.e., action failures.  Initial load failures
        // are covered by the full-screen error view in the builder.
        listenWhen: (previous, current) =>
            (current is QueueManagementError &&
                (previous is QueueManagementLoaded ||
                    previous is QueueManagementActionInFlight)) ||
            current is QueueManagementLoaded,
        listener: (ctx, state) {
          if (state is QueueManagementError) {
            AppSnackBar.showError(ctx, state.message);
          }
          if (state is QueueManagementLoaded &&
              state.feedbackMessage != null &&
              state.feedbackMessage!.trim().isNotEmpty) {
            AppSnackBar.showSuccess(ctx, state.feedbackMessage!);
          }
        },
        builder: (ctx, state) {
          return switch (state) {
            QueueManagementInitial() ||
            QueueManagementLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            QueueManagementError(:final message) => ErrorView(
              message: message,
              onRetry: () => ctx.read<QueueManagementCubit>().watchQueue(
                orgId: orgId,
                date: selectedDate,
              ),
            ),
            QueueManagementLoaded(:final snapshot) => QueueContent(
              snapshot: snapshot,
              isActionInFlight: false,
              orgId: orgId,
              selectedDate: selectedDate,
            ),
            QueueManagementActionInFlight(:final snapshot) => QueueContent(
              snapshot: snapshot,
              isActionInFlight: true,
              orgId: orgId,
              selectedDate: selectedDate,
            ),
          };
        },
      ),
    );
  }
}
