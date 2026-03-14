import 'package:equatable/equatable.dart';

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

/// Emitted while the queue data is being fetched.
final class QueueManagementLoading extends QueueManagementState {
  const QueueManagementLoading();
}

/// Emitted on a data load or queue action error.
final class QueueManagementError extends QueueManagementState {
  const QueueManagementError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// TODO(T016): Add QueueManagementLoaded and QueueManagementActionInFlight
//             once AdminQueueSnapshot view model is defined (Phase 2 / T008).
