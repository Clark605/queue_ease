import 'package:equatable/equatable.dart';

/// Represents working hours for an organization on a specific day of the week.
///
/// Defines when an organization is open for appointments, including optional
/// break times. Each organization should have 7 working hours documents
/// (one for each day of the week, 0=Monday through 6=Sunday).
class WorkingHoursEntity extends Equatable {
  const WorkingHoursEntity({
    required this.orgId,
    required this.dayOfWeek,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    this.breakStart,
    this.breakEnd,
  });

  /// Parent organization ID.
  final String orgId;

  /// Day of the week (0=Monday, 1=Tuesday, ..., 6=Sunday).
  ///
  /// This value also serves as the document ID in Firestore.
  final int dayOfWeek;

  /// Whether the organization is open on this day.
  final bool isOpen;

  /// Opening time in "HH:mm" format (e.g., "09:00").
  final String openTime;

  /// Closing time in "HH:mm" format (e.g., "18:00").
  final String closeTime;

  /// Optional break start time in "HH:mm" format.
  final String? breakStart;

  /// Optional break end time in "HH:mm" format.
  final String? breakEnd;

  @override
  List<Object?> get props => [
    orgId,
    dayOfWeek,
    isOpen,
    openTime,
    closeTime,
    breakStart,
    breakEnd,
  ];
}
