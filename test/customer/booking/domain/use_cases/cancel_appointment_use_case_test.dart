import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/customer/booking/domain/repositories/customer_appointment_repository.dart';
import 'package:queue_ease/features/customer/booking/domain/use_cases/cancel_appointment_use_case.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';

class MockCustomerAppointmentRepository extends Mock
    implements CustomerAppointmentRepository {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late CancelAppointmentUseCase useCase;
  late MockCustomerAppointmentRepository mockRepository;
  late MockAppLogger mockLogger;

  setUpAll(() {
    registerFallbackValue(AppointmentStatus.booked);
  });

  setUp(() {
    mockRepository = MockCustomerAppointmentRepository();
    mockLogger = MockAppLogger();
    when(() => mockLogger.info(any())).thenReturn(null);
    when(() => mockLogger.warning(any())).thenReturn(null);
    useCase = CancelAppointmentUseCase(mockRepository, mockLogger);
  });

  group('CancelAppointmentUseCase', () {
    const orgId = 'org123';
    const appointmentId = 'appt456';

    test('returns Success when appointment status is booked', () async {
      when(
        () => mockRepository.updateAppointmentStatus(
          orgId: any(named: 'orgId'),
          appointmentId: any(named: 'appointmentId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase(
        orgId: orgId,
        appointmentId: appointmentId,
        currentStatus: AppointmentStatus.booked,
      );

      expect(result, isA<Success>());
      verify(
        () => mockRepository.updateAppointmentStatus(
          orgId: orgId,
          appointmentId: appointmentId,
          status: AppointmentStatus.cancelled,
        ),
      ).called(1);
    });

    test('returns Failure when appointment status is inQueue', () async {
      final result = await useCase(
        orgId: orgId,
        appointmentId: appointmentId,
        currentStatus: AppointmentStatus.inQueue,
      );

      expect(result, isA<Failure>());
      final failure = result as Failure;
      expect(
        failure.exception.message,
        'This booking can no longer be cancelled.',
      );
      verifyNever(
        () => mockRepository.updateAppointmentStatus(
          orgId: any(named: 'orgId'),
          appointmentId: any(named: 'appointmentId'),
          status: any(named: 'status'),
        ),
      );
    });

    test('returns Failure when appointment status is completed', () async {
      final result = await useCase(
        orgId: orgId,
        appointmentId: appointmentId,
        currentStatus: AppointmentStatus.completed,
      );

      expect(result, isA<Failure>());
      final failure = result as Failure;
      expect(
        failure.exception.message,
        'This appointment is already completed.',
      );
      verifyNever(
        () => mockRepository.updateAppointmentStatus(
          orgId: any(named: 'orgId'),
          appointmentId: any(named: 'appointmentId'),
          status: any(named: 'status'),
        ),
      );
    });

    test('returns Failure when appointment status is serving', () async {
      final result = await useCase(
        orgId: orgId,
        appointmentId: appointmentId,
        currentStatus: AppointmentStatus.serving,
      );

      expect(result, isA<Failure>());
      final failure = result as Failure;
      expect(
        failure.exception.message,
        'This appointment is currently being served.',
      );
    });

    test('returns Failure when appointment status is cancelled', () async {
      final result = await useCase(
        orgId: orgId,
        appointmentId: appointmentId,
        currentStatus: AppointmentStatus.cancelled,
      );

      expect(result, isA<Failure>());
      final failure = result as Failure;
      expect(
        failure.exception.message,
        'This booking has already been cancelled.',
      );
    });

    test('returns Failure when appointment status is noShow', () async {
      final result = await useCase(
        orgId: orgId,
        appointmentId: appointmentId,
        currentStatus: AppointmentStatus.noShow,
      );

      expect(result, isA<Failure>());
      final failure = result as Failure;
      expect(failure.exception.message, 'This booking was marked as no-show.');
    });

    test('returns Failure when repository update fails', () async {
      when(
        () => mockRepository.updateAppointmentStatus(
          orgId: any(named: 'orgId'),
          appointmentId: any(named: 'appointmentId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => const Failure(DatabaseException('DB error')));

      final result = await useCase(
        orgId: orgId,
        appointmentId: appointmentId,
        currentStatus: AppointmentStatus.booked,
      );

      expect(result, isA<Failure>());
    });
  });
}
