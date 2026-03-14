import 'package:equatable/equatable.dart';

import '../../domain/use_cases/watch_customer_dashboard_use_case.dart';

/// States for [CustomerDashboardCubit].
sealed class CustomerDashboardState extends Equatable {
  const CustomerDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data has been requested.
final class CustomerDashboardInitial extends CustomerDashboardState {
  const CustomerDashboardInitial();
}

/// Emitted while the dashboard stream is being set up.
final class CustomerDashboardLoading extends CustomerDashboardState {
  const CustomerDashboardLoading();
}

/// Emitted when dashboard data is available (may have empty sections).
final class CustomerDashboardLoaded extends CustomerDashboardState {
  const CustomerDashboardLoaded({required this.dashboard});

  final CustomerDashboardView dashboard;

  @override
  List<Object?> get props => [dashboard];
}

/// Emitted on a stream error.
final class CustomerDashboardError extends CustomerDashboardState {
  const CustomerDashboardError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
