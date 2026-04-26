import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/customer/booking/domain/repositories/customer_appointment_repository.dart';
import 'package:queue_ease/features/customer/entry/domain/use_cases/calculate_wait_time_use_case.dart';
import 'package:queue_ease/features/customer/entry/domain/use_cases/watch_customer_queue_status_use_case.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';
import 'package:queue_ease/features/shared_domain/entities/queue_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/queue_status.dart';

class MockCustomerAppointmentRepository extends Mock
    implements CustomerAppointmentRepository {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockCustomerAppointmentRepository mockRepository;
  late MockAppLogger mockLogger;
  late StreamController<Result<AppointmentEntity?>> appointmentController;
  late StreamController<Result<QueueEntity?>> queueController;
  late StreamController<Result<List<QueueAppointmentWaitEntry>>>
  queueAppointmentsController;

  const orgId = 'org-1';
  const customerId = 'customer-1';
  final queueDate = DateTime.utc(2026, 4, 26);

  setUp(() {
    mockRepository = MockCustomerAppointmentRepository();
    mockLogger = MockAppLogger();
    appointmentController = StreamController<Result<AppointmentEntity?>>();
    queueController = StreamController<Result<QueueEntity?>>();
    queueAppointmentsController =
        StreamController<Result<List<QueueAppointmentWaitEntry>>>();

    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.warning(any(), any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);
  });

  tearDown(() async {
    await appointmentController.close();
    await queueController.close();
    await queueAppointmentsController.close();
  });

  group('WatchCustomerQueueStatusUseCase', () {
    test(
      'uses the scheduled appointment time for the first queued customer before the booking time',
      () async {
        final now = DateTime.now().toUtc();
        final scheduledAt = now.add(const Duration(minutes: 15));

        final appointment = AppointmentEntity(
          id: 'appt-1',
          orgId: orgId,
          serviceId: 'service-1',
          customerId: customerId,
          customerName: 'Test Customer',
          scheduledAt: scheduledAt,
          status: AppointmentStatus.booked,
          createdAt: now.subtract(const Duration(days: 1)),
        );
        final queue = QueueEntity(
          id: 'queue-1',
          orgId: orgId,
          date: '2026-04-26',
          orderedAppointmentIds: const ['appt-1'],
          currentServingIndex: 0,
          status: QueueStatus.active,
          generatedAt: now.subtract(const Duration(minutes: 5)),
          updatedAt: now.subtract(const Duration(minutes: 5)),
        );

        when(
          () => mockRepository.watchCustomerQueueAppointment(
            orgId: orgId,
            customerId: customerId,
            date: queueDate,
          ),
        ).thenAnswer((_) => appointmentController.stream);
        when(
          () => mockRepository.watchDailyQueue(orgId: orgId, date: queueDate),
        ).thenAnswer((_) => queueController.stream);
        when(
          () => mockRepository.watchQueueAppointmentsForDate(
            orgId: orgId,
            date: queueDate,
          ),
        ).thenAnswer((_) => queueAppointmentsController.stream);

        final stream = WatchCustomerQueueStatusUseCase(
          mockRepository,
          const CalculateWaitTimeUseCase(),
          mockLogger,
        )(orgId: orgId, customerId: customerId, date: queueDate);

        final future = stream.first;

        appointmentController.add(Success(appointment));
        queueController.add(Success(queue));
        queueAppointmentsController.add(
          Success(const [
            QueueAppointmentWaitEntry(
              appointmentId: 'appt-1',
              status: AppointmentStatus.booked,
              serviceDurationMinutes: 20,
            ),
          ]),
        );

        final result = await future;
        final data = switch (result) {
          Success(:final data) => data,
          Failure() => null,
        };

        expect(data, isNotNull);
        expect(data!.expectedServiceTime, scheduledAt);
        expect(data.estimatedWaitMinutes, inInclusiveRange(14, 15));
      },
    );

    test(
      'keeps the first queued customer at zero wait once the booking time has passed',
      () async {
        final now = DateTime.now().toUtc();
        final scheduledAt = now.subtract(const Duration(minutes: 5));

        final appointment = AppointmentEntity(
          id: 'appt-2',
          orgId: orgId,
          serviceId: 'service-1',
          customerId: customerId,
          customerName: 'Test Customer',
          scheduledAt: scheduledAt,
          status: AppointmentStatus.booked,
          createdAt: now.subtract(const Duration(days: 1)),
        );
        final queue = QueueEntity(
          id: 'queue-1',
          orgId: orgId,
          date: '2026-04-26',
          orderedAppointmentIds: const ['appt-2'],
          currentServingIndex: 0,
          status: QueueStatus.active,
          generatedAt: now.subtract(const Duration(minutes: 5)),
          updatedAt: now.subtract(const Duration(minutes: 5)),
        );

        when(
          () => mockRepository.watchCustomerQueueAppointment(
            orgId: orgId,
            customerId: customerId,
            date: queueDate,
          ),
        ).thenAnswer((_) => appointmentController.stream);
        when(
          () => mockRepository.watchDailyQueue(orgId: orgId, date: queueDate),
        ).thenAnswer((_) => queueController.stream);
        when(
          () => mockRepository.watchQueueAppointmentsForDate(
            orgId: orgId,
            date: queueDate,
          ),
        ).thenAnswer((_) => queueAppointmentsController.stream);

        final stream = WatchCustomerQueueStatusUseCase(
          mockRepository,
          const CalculateWaitTimeUseCase(),
          mockLogger,
        )(orgId: orgId, customerId: customerId, date: queueDate);

        final future = stream.first;

        appointmentController.add(Success(appointment));
        queueController.add(Success(queue));
        queueAppointmentsController.add(
          Success(const [
            QueueAppointmentWaitEntry(
              appointmentId: 'appt-2',
              status: AppointmentStatus.booked,
              serviceDurationMinutes: 20,
            ),
          ]),
        );

        final result = await future;
        final data = switch (result) {
          Success(:final data) => data,
          Failure() => null,
        };

        expect(data, isNotNull);
        expect(data!.expectedServiceTime, isNull);
        expect(data.estimatedWaitMinutes, 0);
      },
    );

    test(
      'clamps non-first customer ETA to booked time when queue-based ETA is earlier',
      () async {
        final now = DateTime.now().toUtc();
        final scheduledAt = now.add(const Duration(minutes: 20));

        final appointment = AppointmentEntity(
          id: 'appt-target',
          orgId: orgId,
          serviceId: 'service-2',
          customerId: customerId,
          customerName: 'Test Customer',
          scheduledAt: scheduledAt,
          status: AppointmentStatus.booked,
          createdAt: now.subtract(const Duration(days: 1)),
        );
        final queue = QueueEntity(
          id: 'queue-2',
          orgId: orgId,
          date: '2026-04-26',
          orderedAppointmentIds: const ['appt-current', 'appt-target'],
          currentServingIndex: 0,
          status: QueueStatus.active,
          generatedAt: now.subtract(const Duration(minutes: 1)),
          updatedAt: now,
        );

        when(
          () => mockRepository.watchCustomerQueueAppointment(
            orgId: orgId,
            customerId: customerId,
            date: queueDate,
          ),
        ).thenAnswer((_) => appointmentController.stream);
        when(
          () => mockRepository.watchDailyQueue(orgId: orgId, date: queueDate),
        ).thenAnswer((_) => queueController.stream);
        when(
          () => mockRepository.watchQueueAppointmentsForDate(
            orgId: orgId,
            date: queueDate,
          ),
        ).thenAnswer((_) => queueAppointmentsController.stream);

        final stream = WatchCustomerQueueStatusUseCase(
          mockRepository,
          const CalculateWaitTimeUseCase(),
          mockLogger,
        )(orgId: orgId, customerId: customerId, date: queueDate);

        final future = stream.first;

        appointmentController.add(Success(appointment));
        queueController.add(Success(queue));
        queueAppointmentsController.add(
          Success(const [
            QueueAppointmentWaitEntry(
              appointmentId: 'appt-current',
              status: AppointmentStatus.booked,
              serviceDurationMinutes: 5,
            ),
            QueueAppointmentWaitEntry(
              appointmentId: 'appt-target',
              status: AppointmentStatus.booked,
              serviceDurationMinutes: 20,
            ),
          ]),
        );

        final result = await future;
        final data = switch (result) {
          Success(:final data) => data,
          Failure() => null,
        };

        expect(data, isNotNull);
        expect(data!.expectedServiceTime, scheduledAt);
        expect(data.estimatedWaitMinutes, inInclusiveRange(19, 20));
      },
    );

    test(
      'keeps non-first customer queue ETA when queue-based ETA is later than booked time',
      () async {
        final now = DateTime.now().toUtc();
        final scheduledAt = now.add(const Duration(minutes: 10));

        final appointment = AppointmentEntity(
          id: 'appt-target-late',
          orgId: orgId,
          serviceId: 'service-3',
          customerId: customerId,
          customerName: 'Test Customer',
          scheduledAt: scheduledAt,
          status: AppointmentStatus.booked,
          createdAt: now.subtract(const Duration(days: 1)),
        );
        final queue = QueueEntity(
          id: 'queue-3',
          orgId: orgId,
          date: '2026-04-26',
          orderedAppointmentIds: const ['appt-current', 'appt-target-late'],
          currentServingIndex: 0,
          status: QueueStatus.active,
          generatedAt: now.subtract(const Duration(minutes: 1)),
          updatedAt: now,
        );

        when(
          () => mockRepository.watchCustomerQueueAppointment(
            orgId: orgId,
            customerId: customerId,
            date: queueDate,
          ),
        ).thenAnswer((_) => appointmentController.stream);
        when(
          () => mockRepository.watchDailyQueue(orgId: orgId, date: queueDate),
        ).thenAnswer((_) => queueController.stream);
        when(
          () => mockRepository.watchQueueAppointmentsForDate(
            orgId: orgId,
            date: queueDate,
          ),
        ).thenAnswer((_) => queueAppointmentsController.stream);

        final stream = WatchCustomerQueueStatusUseCase(
          mockRepository,
          const CalculateWaitTimeUseCase(),
          mockLogger,
        )(orgId: orgId, customerId: customerId, date: queueDate);

        final future = stream.first;

        appointmentController.add(Success(appointment));
        queueController.add(Success(queue));
        queueAppointmentsController.add(
          Success(const [
            QueueAppointmentWaitEntry(
              appointmentId: 'appt-current',
              status: AppointmentStatus.booked,
              serviceDurationMinutes: 30,
            ),
            QueueAppointmentWaitEntry(
              appointmentId: 'appt-target-late',
              status: AppointmentStatus.booked,
              serviceDurationMinutes: 15,
            ),
          ]),
        );

        final result = await future;
        final data = switch (result) {
          Success(:final data) => data,
          Failure() => null,
        };

        expect(data, isNotNull);
        expect(data!.expectedServiceTime!.isAfter(scheduledAt), isTrue);
        expect(data.estimatedWaitMinutes, inInclusiveRange(29, 30));
      },
    );
  });
}
