import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/customer/booking/domain/repositories/customer_appointment_repository.dart';
import 'package:queue_ease/features/customer/booking/domain/use_cases/watch_customer_appointments_use_case.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';

class MockCustomerAppointmentRepository extends Mock
    implements CustomerAppointmentRepository {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late WatchCustomerAppointmentsUseCase useCase;
  late MockCustomerAppointmentRepository mockRepository;
  late MockAppLogger mockLogger;
  late StreamController<Result<List<AppointmentEntity>>> controller;

  setUp(() {
    mockRepository = MockCustomerAppointmentRepository();
    mockLogger = MockAppLogger();
    controller = StreamController<Result<List<AppointmentEntity>>>();

    when(() => mockLogger.info(any(), any())).thenReturn(null);

    useCase = WatchCustomerAppointmentsUseCase(mockRepository, mockLogger);
  });

  tearDown(() async {
    await controller.close();
  });

  test('emits appointments from the repository stream', () async {
    const customerId = 'customer-1';
    final date = DateTime(2026, 5, 21);
    final appointment = AppointmentEntity(
      id: 'appt-1',
      orgId: 'org-1',
      serviceId: 'service-1',
      customerId: customerId,
      customerName: 'Test Customer',
      scheduledAt: DateTime(2026, 5, 21, 10),
      status: AppointmentStatus.completed,
      createdAt: DateTime(2026, 5, 20, 12),
    );

    when(
      () => mockRepository.watchCustomerAppointments(
        customerId: customerId,
        date: date,
      ),
    ).thenAnswer((_) => controller.stream);

    final stream = useCase(customerId: customerId, date: date);

    final expectation = expectLater(
      stream,
      emitsInOrder([
        isA<Success<List<AppointmentEntity>>>().having(
          (result) => result.data,
          'data',
          equals([appointment]),
        ),
        emitsDone,
      ]),
    );

    controller.add(Success([appointment]));
    await controller.close();

    await expectation;
    verify(
      () => mockRepository.watchCustomerAppointments(
        customerId: customerId,
        date: date,
      ),
    ).called(1);
  });
}
