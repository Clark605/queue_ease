/// Represents the status of an appointment in the queue system.
enum AppointmentStatus {
  /// Appointment has been booked but not yet in the active queue.
  booked,

  /// Appointment is in the active queue waiting to be served.
  inQueue,

  /// Customer is currently being served.
  serving,

  /// Service has been completed.
  completed,

  /// Customer did not show up within the grace period.
  noShow,
}
