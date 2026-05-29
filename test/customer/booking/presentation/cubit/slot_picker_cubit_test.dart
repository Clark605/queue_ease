import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/core/config/flavor_config.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';
import 'package:queue_ease/features/customer/booking/presentation/cubit/slot_picker_cubit.dart';
import 'package:queue_ease/features/customer/booking/presentation/cubit/slot_picker_state.dart';
import 'package:queue_ease/features/customer/booking/domain/use_cases/calculate_available_slots_use_case.dart';
import 'package:queue_ease/features/customer/booking/domain/repositories/customer_working_hours_repository.dart';

class _MockWorkingHoursRepo extends Mock
    implements CustomerWorkingHoursRepository {}

class _MockCalculateSlots extends Mock
    implements CalculateAvailableSlotsUseCase {}

class WorkingHoursEntityFake extends Fake implements WorkingHoursEntity {}

void main() {
  late _MockWorkingHoursRepo workingHoursRepo;
  late _MockCalculateSlots calculate;
  late SlotPickerCubit cubit;

  setUp(() {
    workingHoursRepo = _MockWorkingHoursRepo();
    calculate = _MockCalculateSlots();

    registerFallbackValue(WorkingHoursEntityFake());

    final logger = AppLogger(FlavorConfig.dev());
    cubit = SlotPickerCubit(calculate, workingHoursRepo, logger);
  });

  test('refreshes slots when working-hours stream emits', () async {
    final orgId = 'org-1';
    final serviceId = 'svc-1';
    final dayIndex = DateTime.now().weekday - 1;

    final controller = StreamController<List<WorkingHoursEntity>>();
    when(
      () => workingHoursRepo.watchWorkingHours(orgId),
    ).thenAnswer((_) => controller.stream);

    // return a non-empty slot list so initial open state yields Loaded
    when(
      () => calculate.call(
        orgId: any(named: 'orgId'),
        serviceId: any(named: 'serviceId'),
        date: any(named: 'date'),
        workingHours: any(named: 'workingHours'),
        serviceDurationMinutes: any(named: 'serviceDurationMinutes'),
        currentTime: any(named: 'currentTime'),
      ),
    ).thenAnswer(
      (_) async => Success([DateTime.now().add(const Duration(hours: 1))]),
    );

    await cubit.init(orgId: orgId, serviceId: serviceId, durationMinutes: 15);

    // emit first working hours entry (open)
    controller.add([
      WorkingHoursEntity(
        orgId: orgId,
        dayOfWeek: dayIndex,
        isOpen: true,
        openTime: '08:00',
        closeTime: '17:00',
      ),
    ]);

    // allow async listeners to run
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(cubit.state, isA<SlotPickerLoaded>());

    // emit an update (closed day)
    controller.add([
      WorkingHoursEntity(
        orgId: orgId,
        dayOfWeek: dayIndex,
        isOpen: false,
        openTime: '00:00',
        closeTime: '00:00',
      ),
    ]);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(cubit.state, isA<SlotPickerNoSlots>());

    await controller.close();
    await cubit.close();
  });
}
