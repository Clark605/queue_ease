import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/admin_appointment_repository.dart';
import '../cubit/queue_management_cubit.dart';
import 'current_queue_card.dart';
import 'empty_queue_state.dart';
import 'queue_action_bar.dart';
import 'queue_date_header.dart';
import 'waiting_queue_list.dart';

/// Scrollable queue content shown when the cubit is in a loaded or
/// action-in-flight state.
class QueueContent extends StatelessWidget {
  const QueueContent({
    super.key,
    required this.snapshot,
    required this.isActionInFlight,
    required this.orgId,
  });

  final AdminQueueSnapshot snapshot;
  final bool isActionInFlight;
  final String orgId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QueueDateHeader(date: DateTime.now()),
          const SizedBox(height: 16),
          if (snapshot.current != null) ...[
            CurrentQueueCard(
              entry: snapshot.current!,
              isActionInFlight: isActionInFlight,
              onNext: snapshot.current!.allowedActions.canComplete
                  ? () => context.read<QueueManagementCubit>().next(
                      orgId: orgId,
                      date: DateTime.now(),
                      appointmentId: snapshot.current!.appointmentId,
                    )
                  : snapshot.current!.allowedActions.canStartServing
                  ? () => context.read<QueueManagementCubit>().startServing(
                      orgId: orgId,
                      date: DateTime.now(),
                      appointmentId: snapshot.current!.appointmentId,
                    )
                  : null,
              onSkip: snapshot.current!.allowedActions.canSkip
                  ? () => context.read<QueueManagementCubit>().skip(
                      orgId: orgId,
                      date: DateTime.now(),
                      appointmentId: snapshot.current!.appointmentId,
                    )
                  : null,
              onNoShow: snapshot.current!.allowedActions.canMarkNoShow
                  ? () => context.read<QueueManagementCubit>().markNoShow(
                      orgId: orgId,
                      date: DateTime.now(),
                      appointmentId: snapshot.current!.appointmentId,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
          ] else if (snapshot.waiting.isEmpty) ...[
            EmptyQueueState(
              onGenerate: () => context
                  .read<QueueManagementCubit>()
                  .generateQueue(orgId: orgId, date: DateTime.now()),
            ),
            const SizedBox(height: 16),
          ],
          WaitingQueueList(
            entries: snapshot.waiting,
            isActionInFlight: isActionInFlight,
            onRejoin: (appointmentId) =>
                context.read<QueueManagementCubit>().rejoin(
                  orgId: orgId,
                  date: DateTime.now(),
                  appointmentId: appointmentId,
                ),
          ),
          const SizedBox(height: 16),
          QueueActionBar(
            waitingCount: snapshot.waiting.length,
            queueEmpty: snapshot.current == null && snapshot.waiting.isEmpty,
          ),
        ],
      ),
    );
  }
}
