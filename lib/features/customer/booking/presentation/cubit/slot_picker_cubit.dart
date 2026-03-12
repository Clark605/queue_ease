import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/error/result.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../shared_domain/entities/working_hours_entity.dart';
import '../../domain/repositories/customer_working_hours_repository.dart';
import '../../domain/use_cases/calculate_available_slots_use_case.dart';
import 'slot_picker_state.dart';

@injectable
class SlotPickerCubit extends Cubit<SlotPickerState> {
  SlotPickerCubit(
    this._calculateAvailableSlots,
    this._workingHoursRepository,
    this._logger,
  ) : super(const SlotPickerInitial());

  final CalculateAvailableSlotsUseCase _calculateAvailableSlots;
  final CustomerWorkingHoursRepository _workingHoursRepository;
  final AppLogger _logger;

  late List<WorkingHoursEntity> _workingHours;
  late String _orgId;
  late String _serviceId;
  late int _durationMinutes;

  /// Loads working hours for [orgId] and then calculates slots for today.
  Future<void> init({
    required String orgId,
    required String serviceId,
    required int durationMinutes,
  }) async {
    _orgId = orgId;
    _serviceId = serviceId;
    _durationMinutes = durationMinutes;
    _logger.debug(
      'SlotPickerCubit: init orgId=$orgId serviceId=$serviceId '
      'duration=$durationMinutes min',
    );

    try {
      _workingHours = await _workingHoursRepository
          .watchWorkingHours(orgId)
          .first;
      _logger.debug(
        'SlotPickerCubit: fetched ${_workingHours.length} working hour entries',
      );
      await loadSlotsForDate(DateTime.now());
    } catch (e, st) {
      _logger.error('SlotPickerCubit: failed to init', e, st);
      emit(const SlotPickerError('Failed to load availability.'));
    }
  }

  /// Calculates available slots for [date] and emits the appropriate state.
  Future<void> loadSlotsForDate(DateTime date) async {
    final closedIndices = _closedDayIndices();
    emit(
      SlotPickerLoading(selectedDate: date, closedDayIndices: closedIndices),
    );

    // Find the working-hours entry for this weekday
    final dayIndex = date.weekday - 1; // 0=Mon … 6=Sun
    final entries = _workingHours.where((wh) => wh.dayOfWeek == dayIndex);

    if (entries.isEmpty || !entries.first.isOpen) {
      _logger.debug('SlotPickerCubit: dayIndex=$dayIndex is closed');
      emit(
        SlotPickerNoSlots(selectedDate: date, closedDayIndices: closedIndices),
      );
      return;
    }

    final result = await _calculateAvailableSlots(
      orgId: _orgId,
      serviceId: _serviceId,
      date: date,
      workingHours: entries.first,
      serviceDurationMinutes: _durationMinutes,
      currentTime: DateTime.now(),
    );

    switch (result) {
      case Failure(:final exception):
        _logger.error(
          'SlotPickerCubit: slot calculation failed for date=${date.toIso8601String()}',
          exception,
        );
        emit(SlotPickerError(exception.message));
      case Success(:final data) when data.isEmpty:
        _logger.warning(
          'SlotPickerCubit: no available slots for date=${date.toIso8601String()}',
        );
        emit(
          SlotPickerNoSlots(
            selectedDate: date,
            closedDayIndices: closedIndices,
          ),
        );
      case Success(:final data):
        _logger.debug(
          'SlotPickerCubit: ${data.length} slots for date=${date.toIso8601String()}',
        );
        emit(
          SlotPickerLoaded(
            selectedDate: date,
            availableSlots: data,
            closedDayIndices: closedIndices,
          ),
        );
    }
  }

  /// Marks [slot] as the user's selection within the current loaded state.
  void selectSlot(DateTime slot) {
    final current = state;
    if (current is SlotPickerLoaded) {
      _logger.debug('SlotPickerCubit: slot selected ${slot.toIso8601String()}');
      emit(current.copyWith(selectedSlot: slot));
    }
  }

  Set<int> _closedDayIndices() =>
      _workingHours.where((wh) => !wh.isOpen).map((wh) => wh.dayOfWeek).toSet();
}
