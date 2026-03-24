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
/// Supports pull-to-refresh to handle missed real-time updates.
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
            CustomerQueueStatusEmpty() => _EmptyView(
              onRefresh: () => _onRefresh(context),
            ),
            CustomerQueueStatusError(:final message) => _ErrorView(
              message: message,
              onRefresh: () => _onRefresh(context),
            ),
            CustomerQueueStatusLoaded(:final status) => _LoadedView(
              status: status,
              onRefresh: () => _onRefresh(context),
            ),
          };
        },
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final cubit = context.read<CustomerQueueStatusCubit>();
    cubit.refreshStatus();

    // Wait for the refresh to complete
    await cubit.stream
        .where((state) => state is! CustomerQueueStatusLoading)
        .first;
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
  const _EmptyView({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_empty_outlined,
                  size: 48,
                  color: AppColors.onSurfaceVariant,
                ),
                SizedBox(height: 16),
                Text('Not in queue', style: AppTextStyles.headlineSmall),
                SizedBox(height: 8),
                Text(
                  "You don't have an active queue entry for today.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRefresh});

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.status, required this.onRefresh});

  final CustomerQueueStatusView status;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (status.isNoShow) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            NoShowQueueCard(status: status),
            const SizedBox(height: 16),
            const _NoShowInfoNote(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
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
