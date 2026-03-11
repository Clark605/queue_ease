import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_snack_bar.dart';

/// Queue management page for managing the live queue.
///
/// Displays the current queue and allows admins to:
/// - View waiting customers
/// - Call next customer
/// - Mark as no-show
/// - Complete appointments
class QueueManagementPage extends StatelessWidget {
  const QueueManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        title: Text(
          'Queue Management',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            color: AppColors.onSurfaceVariant,
            onPressed: () => AppSnackBar.showInfo(context, 'Filter - Coming soon'),
            tooltip: 'Filter',
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
      body: _buildEmptyState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.queue_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Queue Today',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Queue management will be available when customers join the queue',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => AppSnackBar.showInfo(context, 'View history - Coming soon'),
              icon: const Icon(Icons.history),
              label: const Text('View History'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future implementation: List view of queue items
  // Widget _buildQueueList() {
  //   return ListView.separated(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: 10,
  //     separatorBuilder: (context, index) => const SizedBox(height: 8),
  //     itemBuilder: (context, index) {
  //       return _QueueItemCard(
  //         position: index + 1,
  //         customerName: 'Customer ${index + 1}',
  //         serviceName: 'Service Name',
  //         status: index == 0 ? 'Current' : 'Waiting',
  //       );
  //     },
  //   );
  // }
}
