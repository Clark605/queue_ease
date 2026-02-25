/// Represents the operational status of a daily queue.
enum QueueStatus {
  /// Queue is actively processing customers.
  active,

  /// Queue is temporarily paused.
  paused,

  /// Queue is closed for the day.
  closed,
}
