import 'package:equatable/equatable.dart';

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

// TODO(T024): Add CustomerQueueStatusLoaded with CustomerQueueStatusView
//             once the view model is defined (Phase 4).
