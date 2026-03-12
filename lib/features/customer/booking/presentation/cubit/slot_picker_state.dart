import 'package:equatable/equatable.dart';

sealed class SlotPickerState extends Equatable {
  const SlotPickerState();

  @override
  List<Object?> get props => [];
}

/// Before working hours are loaded.
final class SlotPickerInitial extends SlotPickerState {
  const SlotPickerInitial();
}

/// Working hours loaded; calculating slots for [selectedDate].
/// [closedDayIndices] allows the DateSelector to remain visible during loads.
final class SlotPickerLoading extends SlotPickerState {
  const SlotPickerLoading({
    required this.selectedDate,
    required this.closedDayIndices,
  });

  final DateTime selectedDate;

  /// Set of weekday indices (0=Mon … 6=Sun) with no working hours / closed.
  final Set<int> closedDayIndices;

  @override
  List<Object?> get props => [selectedDate, closedDayIndices];
}

/// Slots calculated and ready for selection.
final class SlotPickerLoaded extends SlotPickerState {
  const SlotPickerLoaded({
    required this.selectedDate,
    required this.availableSlots,
    required this.closedDayIndices,
    this.selectedSlot,
  });

  final DateTime selectedDate;
  final List<DateTime> availableSlots;
  final Set<int> closedDayIndices;
  final DateTime? selectedSlot;

  SlotPickerLoaded copyWith({DateTime? selectedSlot}) => SlotPickerLoaded(
    selectedDate: selectedDate,
    availableSlots: availableSlots,
    closedDayIndices: closedDayIndices,
    selectedSlot: selectedSlot,
  );

  @override
  List<Object?> get props => [
    selectedDate,
    availableSlots,
    closedDayIndices,
    selectedSlot,
  ];
}

/// [selectedDate] has no bookable slots (closed day or all occupied).
final class SlotPickerNoSlots extends SlotPickerState {
  const SlotPickerNoSlots({
    required this.selectedDate,
    required this.closedDayIndices,
  });

  final DateTime selectedDate;
  final Set<int> closedDayIndices;

  @override
  List<Object?> get props => [selectedDate, closedDayIndices];
}

/// Unrecoverable failure (e.g. network error).
final class SlotPickerError extends SlotPickerState {
  const SlotPickerError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
