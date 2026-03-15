import 'package:equatable/equatable.dart';

import '../../domain/repositories/admin_appointment_repository.dart';

/// States for [QueueManagementCubit].
sealed class QueueManagementState extends Equatable {
  const QueueManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the queue is loaded.
final class QueueManagementInitial extends QueueManagementState {
  const QueueManagementInitial();
}

/// Emitted while the queue data is being fetched for the first time.
final class QueueManagementLoading extends QueueManagementState {
  const QueueManagementLoading();
}

/// Emitted when queue data is loaded and displayed.
final class QueueManagementLoaded extends QueueManagementState {
  QueueManagementLoaded({required this.snapshot, required this.evaluatedAt});

  final AdminQueueSnapshot snapshot;
  final DateTime evaluatedAt;

  @override
  List<Object?> get props => [snapshot, evaluatedAt];
}

/// Emitted while an action (next/skip/noShow/rejoin) is in flight.
///
/// Carries the current snapshot so the UI remains rendered during the
/// async operation. The UI should disable action buttons in this state.
final class QueueManagementActionInFlight extends QueueManagementState {
  QueueManagementActionInFlight({
    required this.snapshot,
    required this.evaluatedAt,
  });

  final AdminQueueSnapshot snapshot;
  final DateTime evaluatedAt;

  @override
  List<Object?> get props => [snapshot, evaluatedAt];
}

/// Emitted on a data load or queue action error.
final class QueueManagementError extends QueueManagementState {
  const QueueManagementError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
