import 'admin_queue_repository.dart';
import 'queue_use_cases.dart';

/// Contract: Cubit states for admin queue management and customer queue status.

sealed class QueueManagementState {
  const QueueManagementState();
}

final class QueueManagementInitial extends QueueManagementState {
  const QueueManagementInitial();
}

final class QueueManagementLoading extends QueueManagementState {
  const QueueManagementLoading();
}

final class QueueManagementLoaded extends QueueManagementState {
  const QueueManagementLoaded({required this.snapshot});

  final AdminQueueSnapshot snapshot;
}

final class QueueManagementActionInFlight extends QueueManagementState {
  const QueueManagementActionInFlight({required this.snapshot});

  final AdminQueueSnapshot snapshot;
}

final class QueueManagementError extends QueueManagementState {
  const QueueManagementError({required this.message});

  final String message;
}

sealed class CustomerQueueStatusState {
  const CustomerQueueStatusState();
}

final class CustomerQueueStatusInitial extends CustomerQueueStatusState {
  const CustomerQueueStatusInitial();
}

final class CustomerQueueStatusLoading extends CustomerQueueStatusState {
  const CustomerQueueStatusLoading();
}

final class CustomerQueueStatusLoaded extends CustomerQueueStatusState {
  const CustomerQueueStatusLoaded({required this.status});

  final CustomerQueueStatusView status;
}

final class CustomerQueueStatusEmpty extends CustomerQueueStatusState {
  const CustomerQueueStatusEmpty();
}

final class CustomerQueueStatusError extends CustomerQueueStatusState {
  const CustomerQueueStatusError({required this.message});

  final String message;
}
