import 'package:equatable/equatable.dart';

import '../../domain/use_cases/watch_customer_queue_status_use_case.dart';

/// States for [CustomerQueueStatusCubit].
sealed class CustomerQueueStatusState extends Equatable {
  const CustomerQueueStatusState();

  @override
  List<Object?> get props => [];
}

/// Initial state before queue status is loaded.
final class CustomerQueueStatusInitial extends CustomerQueueStatusState {
  const CustomerQueueStatusInitial();
}

/// Emitted while queue status is being fetched.
final class CustomerQueueStatusLoading extends CustomerQueueStatusState {
  const CustomerQueueStatusLoading();
}

/// Emitted when the customer has no active queue entry for today.
final class CustomerQueueStatusEmpty extends CustomerQueueStatusState {
  const CustomerQueueStatusEmpty();
}

/// Emitted on a fetch or stream error.
final class CustomerQueueStatusError extends CustomerQueueStatusState {
  const CustomerQueueStatusError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when queue status data is available.
final class CustomerQueueStatusLoaded extends CustomerQueueStatusState {
  const CustomerQueueStatusLoaded({required this.status});

  final CustomerQueueStatusView status;

  @override
  List<Object?> get props => [status];
}
