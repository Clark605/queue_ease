import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/use_cases/watch_customer_queue_status_use_case.dart';
import '../../../../../features/shared_domain/entities/appointment_entity.dart';
import '../../../../../features/shared_domain/entities/appointment_status.dart';
import 'queue_stat_cell.dart';

/// Card showing the customer's active queue status on the dashboard.
///
/// Renders a blue surface with the current position and estimated wait pulled
/// from [queueStatus]. Shows a loading row when [queueStatus] is null and the
/// stream has not yet emitted.
///
/// The "View My Queue" action has been moved to the page level — this card
/// only presents status information with the hourglass icon decorator.
class ActiveQueueStatusCard extends StatelessWidget {
  const ActiveQueueStatusCard({
    super.key,
    required this.appointment,
    this.queueStatus,
    this.onCancel,
  });

  final VoidCallback? onCancel;

  final AppointmentEntity appointment;
  final CustomerQueueStatusView? queueStatus;

  String get _organizationLabel => appointment.orgName ?? appointment.orgId;

  @override
  Widget build(BuildContext context) {
    final isServing = appointment.status == AppointmentStatus.serving;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isServing),
          const SizedBox(height: 16),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isServing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isServing ? 'Your Turn!' : 'You are in queue',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _organizationLabel,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if ((appointment.status == AppointmentStatus.booked ||
                appointment.status == AppointmentStatus.inQueue) &&
            onCancel != null)
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel, color: Colors.white),
            tooltip: 'Cancel booking',
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.hourglass_empty,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final status = queueStatus;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: status == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: QueueStatCell(
                    label: 'POSITION',
                    value: status.position != null
                        ? '#${status.position}'
                        : '--',
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: Colors.white.withValues(alpha: 0.20),
                ),
                Expanded(
                  child: QueueStatCell(
                    label: 'EST. WAIT',
                    value: status.estimatedWaitMinutes != null
                        ? '${status.estimatedWaitMinutes} min'
                        : '--',
                  ),
                ),
              ],
            ),
    );
  }
}
