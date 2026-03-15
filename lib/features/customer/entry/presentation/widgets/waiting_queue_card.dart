import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/use_cases/watch_customer_queue_status_use_case.dart';
import 'live_indicator.dart';

/// Card shown while the customer is waiting in the queue.
///
/// Displays a live pulsing indicator, the queue position, a progress bar,
/// and stats for the currently-serving position and estimated wait.
class WaitingQueueCard extends StatelessWidget {
  const WaitingQueueCard({super.key, required this.status});

  final CustomerQueueStatusView status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const LiveIndicator(),
          const SizedBox(height: 20),
          Text(
            '#${status.position ?? "-"}',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status.position != null ? 'You are in queue' : 'Booking confirmed',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            status.position != null
                ? 'Please wait nearby'
                : 'Queue has not started yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressSection(),
          const SizedBox(height: 20),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Now serving: #${status.currentServingIndicator ?? "-"}',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              'Your position: #${status.position ?? "-"}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progressValue(),
            backgroundColor: AppColors.outline,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final waitLabel = status.estimatedWaitMinutes != null
        ? '${status.estimatedWaitMinutes} min'
        : '—';
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'SERVING',
            value: '#${status.currentServingIndicator ?? "-"}',
            icon: Icons.person_pin_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'EST. WAIT',
            value: waitLabel,
            icon: Icons.schedule_outlined,
          ),
        ),
      ],
    );
  }

  /// Returns `currentServingIndicator / position` clamped to [0, 1].
  double _progressValue() {
    final serving = status.currentServingIndicator;
    final pos = status.position;
    if (serving == null || pos == null || pos <= 1) return 0.0;
    return (serving / pos).clamp(0.0, 1.0);
  }
}

/// A compact stat card showing an icon, a short label, and a value.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
