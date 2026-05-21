import 'package:flutter/material.dart';

import '../../domain/use_cases/watch_customer_queue_status_use_case.dart';
import 'no_show_queue_card.dart';
import 'service_completed_queue_card.dart';
import 'waiting_queue_card.dart';
import 'your_turn_queue_card.dart';

/// Displays the customer's current queue position and live status.
///
/// Delegates to [NoShowQueueCard], [ServiceCompletedQueueCard],
/// [YourTurnQueueCard], or [WaitingQueueCard] based on live status flags.
class QueuePositionCard extends StatelessWidget {
  const QueuePositionCard({super.key, required this.status});

  final CustomerQueueStatusView status;

  @override
  Widget build(BuildContext context) {
    if (status.isNoShow) return NoShowQueueCard(status: status);
    if (status.isCompleted) return ServiceCompletedQueueCard(status: status);
    if (status.isCurrentTurn) return YourTurnQueueCard(status: status);
    return WaitingQueueCard(status: status);
  }
}
