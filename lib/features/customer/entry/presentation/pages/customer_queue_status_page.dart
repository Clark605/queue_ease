import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/use_cases/watch_customer_queue_status_use_case.dart';
import '../cubit/customer_queue_status_cubit.dart';
import '../cubit/customer_queue_status_state.dart';
import '../widgets/no_show_queue_card.dart';
import '../widgets/queue_position_card.dart';
import '../widgets/wait_time_chip.dart';

/// Displays the customer's live queue position and status.
///
/// Connects to [CustomerQueueStatusCubit] and renders the appropriate
/// view based on the current state. Uses [BlocBuilder] for live stream updates.
class CustomerQueueStatusPage extends StatelessWidget {
  const CustomerQueueStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        title: Text(
          'Queue Status',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<CustomerQueueStatusCubit, CustomerQueueStatusState>(
        builder: (context, state) {
          return switch (state) {
            CustomerQueueStatusInitial() ||
            CustomerQueueStatusLoading() => const _LoadingView(),
            CustomerQueueStatusEmpty() => const _EmptyView(),
            CustomerQueueStatusError(:final message) => _ErrorView(
              message: message,
            ),
            CustomerQueueStatusLoaded(:final status) => _LoadedView(
              status: status,
            ),
          };
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_empty_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Not in queue',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You don't have an active queue entry for today.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.status});

  final CustomerQueueStatusView status;

  @override
  Widget build(BuildContext context) {
    if (status.isNoShow) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            NoShowQueueCard(status: status),
            const SizedBox(height: 16),
            const _NoShowInfoNote(),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          QueuePositionCard(status: status),
          const SizedBox(height: 12),
          WaitTimeChip(status: status),
          const SizedBox(height: 16),
          const _InfoNote(),
        ],
      ),
    );
  }
}

class _NoShowInfoNote extends StatelessWidget {
  const _NoShowInfoNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.support_agent, size: 14, color: AppColors.onSurfaceVariant),
        SizedBox(width: 6),
        Text(
          'Please contact the business if you want to rejoin the queue.',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

/// Small informational note reminding the customer updates are automatic.
class _InfoNote extends StatelessWidget {
  const _InfoNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, size: 14, color: AppColors.onSurfaceVariant),
        SizedBox(width: 6),
        Text(
          'Queue position updates automatically in real time.',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
