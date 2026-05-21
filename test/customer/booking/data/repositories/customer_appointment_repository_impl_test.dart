import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/customer/booking/data/datasources/customer_appointment_datasource.dart';
import 'package:queue_ease/features/customer/booking/data/repositories/customer_appointment_repository_impl.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';

class MockCustomerAppointmentDatasource extends Mock
    implements CustomerAppointmentDatasource {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockCustomerAppointmentDatasource mockDatasource;
  late MockAppLogger mockLogger;
  late CustomerAppointmentRepositoryImpl repository;
  late StreamController<List<AppointmentEntity>> controller;

  const customerId = 'customer-1';
  final date = DateTime(2026, 5, 21);

  setUp(() {
    mockDatasource = MockCustomerAppointmentDatasource();
    mockLogger = MockAppLogger();
    controller = StreamController<List<AppointmentEntity>>();

    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);

    repository = CustomerAppointmentRepositoryImpl(mockDatasource, mockLogger);
  });

  tearDown(() async {
    await controller.close();
  });

  test('wraps datasource stream values in Success', () async {
    final appointment = AppointmentEntity(
      id: 'appt-1',
      orgId: 'org-1',
      serviceId: 'service-1',
      customerId: customerId,
      customerName: 'Test Customer',
      scheduledAt: DateTime(2026, 5, 21, 10),
      status: AppointmentStatus.booked,
      createdAt: DateTime(2026, 5, 20, 12),
    );

    when(
      () => mockDatasource.watchCustomerAppointments(
        customerId: customerId,
        date: date,
      ),
    ).thenAnswer((_) => controller.stream);

    final stream = repository.watchCustomerAppointments(
      customerId: customerId,
      date: date,
    );

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

    controller.add([appointment]);
    await controller.close();

    await expectation;
  });

  test('wraps AppException errors in Failure', () async {
    when(
      () => mockDatasource.watchCustomerAppointments(
        customerId: customerId,
        date: date,
      ),
    ).thenAnswer((_) => controller.stream);

    final stream = repository.watchCustomerAppointments(
      customerId: customerId,
      date: date,
    );

    final expectation = expectLater(
      stream,
      emitsInOrder([
        isA<Failure<List<AppointmentEntity>>>().having(
          (result) => result.exception,
          'exception',
          isA<DatabaseException>(),
        ),
        emitsDone,
      ]),
    );

    controller.addError(const DatabaseException('DB failure'));
    await controller.close();

    await expectation;
  });

  test('wraps unexpected errors in UnknownException', () async {
    when(
      () => mockDatasource.watchCustomerAppointments(
        customerId: customerId,
        date: date,
      ),
    ).thenAnswer((_) => controller.stream);

    final stream = repository.watchCustomerAppointments(
      customerId: customerId,
      date: date,
    );

    final expectation = expectLater(
      stream,
      emitsInOrder([
        isA<Failure<List<AppointmentEntity>>>().having(
          (result) => result.exception,
          'exception',
          isA<UnknownException>(),
        ),
        emitsDone,
      ]),
    );

    controller.addError(Exception('boom'));
    await controller.close();

    await expectation;
  });
}
