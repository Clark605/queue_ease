import 'package:equatable/equatable.dart';

/// Ephemeral form state for the service add / edit screen.
///
/// Owns only the values that change reactively inside the form before
/// submission: the stepper counters and the active toggle. Text fields are
/// handled by [TextEditingController]s in the widget layer since they require
/// [TextEditingController.dispose] lifecycle management.
final class ServiceFormState extends Equatable {
  const ServiceFormState({
    required this.duration,
    required this.margin,
    required this.isActive,
  });

  /// Default duration used when creating a new service.
  static const int defaultDuration = 15;

  /// Default time margin used when creating a new service.
  static const int defaultMargin = 5;

  /// Current duration value in minutes.
  final int duration;

  /// Current time margin value in minutes.
  final int margin;

  /// Whether the service is currently set as active.
  final bool isActive;

  ServiceFormState copyWith({int? duration, int? margin, bool? isActive}) {
    return ServiceFormState(
      duration: duration ?? this.duration,
      margin: margin ?? this.margin,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [duration, margin, isActive];
}
