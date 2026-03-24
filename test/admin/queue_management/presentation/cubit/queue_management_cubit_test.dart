import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/admin/queue_management/domain/models/queue_automation_state.dart';
import 'package:queue_ease/features/admin/queue_management/domain/repositories/admin_appointment_repository.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/advance_queue_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/generate_daily_queue_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/mark_no_show_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/rejoin_skipped_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/skip_queue_entry_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/watch_daily_queue_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart';
import 'package:queue_ease/features/admin/queue_management/presentation/cubit/queue_management_state.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';

class MockAdminAppointmentRepository extends Mock
    implements AdminAppointmentRepository {}

class MockGenerateDailyQueueUseCase extends Mock
    implements GenerateDailyQueueUseCase {}

class MockWatchDailyQueueUseCase extends Mock
    implements WatchDailyQueueUseCase {}

class MockAdvanceQueueUseCase extends Mock implements AdvanceQueueUseCase {}

class MockSkipQueueEntryUseCase extends Mock implements SkipQueueEntryUseCase {}

class MockMarkNoShowUseCase extends Mock implements MarkNoShowUseCase {}

class MockRejoinSkippedUseCase extends Mock implements RejoinSkippedUseCase {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  group('QueueManagementCubit', () {
    late QueueManagementCubit cubit;
    late MockAdminAppointmentRepository mockRepository;
    late MockGenerateDailyQueueUseCase mockGenerateQueue;
    late MockWatchDailyQueueUseCase mockWatchDailyQueue;
    late MockAdvanceQueueUseCase mockAdvanceQueue;
    late MockSkipQueueEntryUseCase mockSkipQueueEntry;
    late MockMarkNoShowUseCase mockMarkNoShow;
    late MockRejoinSkippedUseCase mockRejoinSkipped;
    late MockAppLogger mockLogger;

    // Test data
    final testOrgId = 'org1';
    final testDate = DateTime(2026, 3, 23);
    final testAppointmentId = 'appt1';

    // Create test appointment with automation state
    QueueEntryView createTestQueueEntry({
      required String appointmentId,
      required AppointmentStatus status,
      required QueueAutomationState automationState,
      String customerName = 'Test Customer',
      int position = 1,
    }) {
      final scheduledAt = DateTime(2026, 3, 23, 10, 0);
      final marginMinutes = 5;
      return QueueEntryView(
        appointmentId: appointmentId,
        position: position,
        customerName: customerName,
        serviceDurationMinutes: 30,
        status: status,
        estimatedWaitMinutes: null,
        scheduledAt: scheduledAt,
        effectiveTimeMarginMinutes: marginMinutes,
        noShowDeadline: scheduledAt.add(Duration(minutes: marginMinutes)),
        automationState: automationState,
        allowedActions: const QueueAllowedActions(
          canStartServing: true,
          canComplete: false,
          canSkip: true,
          canMarkNoShow: true,
        ),
      );
    }

    AdminQueueSnapshot createTestSnapshot({
      QueueEntryView? current,
      List<QueueEntryView>? waiting,
    }) {
      return AdminQueueSnapshot(
        queueDate: testDate,
        current: current,
        waiting: waiting ?? [],
      );
    }

    setUp(() {
      mockRepository = MockAdminAppointmentRepository();
      mockGenerateQueue = MockGenerateDailyQueueUseCase();
      mockWatchDailyQueue = MockWatchDailyQueueUseCase();
      mockAdvanceQueue = MockAdvanceQueueUseCase();
      mockSkipQueueEntry = MockSkipQueueEntryUseCase();
      mockMarkNoShow = MockMarkNoShowUseCase();
      mockRejoinSkipped = MockRejoinSkippedUseCase();
      mockLogger = MockAppLogger();

      cubit = QueueManagementCubit(
        mockRepository,
        mockGenerateQueue,
        mockWatchDailyQueue,
        mockAdvanceQueue,
        mockSkipQueueEntry,
        mockMarkNoShow,
        mockRejoinSkipped,
        mockLogger,
      );

      // Register fallbacks for mocktail
      registerFallbackValue(DateTime.now());
    });

    tearDown(() {
      cubit.close();
    });

    group('watchQueue', () {
      test('initial state is QueueManagementInitial', () {
        expect(cubit.state, isA<QueueManagementInitial>());
      });

      blocTest<QueueManagementCubit, QueueManagementState>(
        'emits [Loading, Loaded] when watchDailyQueue succeeds',
        build: () {
          when(() => mockWatchDailyQueue.call(orgId: testOrgId, date: testDate))
              .thenAnswer((_) => Stream.value(Success(AdminQueueSnapshot(
                    queueDate: testDate,
                    current: null,
                    waiting: const [],
                  ))));
          when(() => mockRepository.watchAppointmentsByDate(
                orgId: testOrgId,
                date: testDate,
              )).thenAnswer((_) => Stream.value([]));

          return cubit;
        },
        act: (cubit) async {
          cubit.watchQueue(orgId: testOrgId, date: testDate);
          await Future.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          isA<QueueManagementLoading>(),
          isA<QueueManagementLoaded>(),
        ],
        verify: (cubit) {
          verify(() => mockWatchDailyQueue.call(orgId: testOrgId, date: testDate))
              .called(1);
        },
      );

      blocTest<QueueManagementCubit, QueueManagementState>(
        'emits [Loading, Error] when watchDailyQueue fails',
        build: () {
          when(() => mockWatchDailyQueue.call(orgId: testOrgId, date: testDate))
              .thenAnswer((_) => Stream.value(const Failure(
                    DatabaseException('Failed to load queue'))));
          when(() => mockRepository.watchAppointmentsByDate(
                orgId: testOrgId,
                date: testDate,
              )).thenAnswer((_) => Stream.value([]));

          return cubit;
        },
        act: (cubit) async {
          cubit.watchQueue(orgId: testOrgId, date: testDate);
          await Future.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          isA<QueueManagementLoading>(),
          isA<QueueManagementError>(),
        ],
      );
    });

    group('auto no-show detection', () {
      blocTest<QueueManagementCubit, QueueManagementState>(
        'triggers auto no-show when current entry is overdue',
        build: () {
          when(() => mockWatchDailyQueue.call(orgId: testOrgId, date: testDate))
              .thenAnswer((_) => Stream.value(Success(createTestSnapshot(
                    current: createTestQueueEntry(
                      appointmentId: testAppointmentId,
                      status: AppointmentStatus.inQueue,
                      automationState: QueueAutomationState.overdue,
                    ),
                  ))));
          when(() => mockRepository.watchAppointmentsByDate(
                orgId: testOrgId,
                date: testDate,
              )).thenAnswer((_) => Stream.value([]));
          when(() => mockRepository.markOverdueNoShow(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).thenAnswer((_) async => const Success(null));

          return cubit;
        },
        act: (cubit) async {
          cubit.watchQueue(orgId: testOrgId, date: testDate);
          await Future.delayed(const Duration(milliseconds: 100)); // Allow auto no-show to process
        },
        expect: () => [
          isA<QueueManagementLoading>(),
          isA<QueueManagementLoaded>(),
          isA<QueueManagementLoaded>(),
        ],
        verify: (cubit) {
          verify(() => mockRepository.markOverdueNoShow(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).called(1);
        },
      );

      blocTest<QueueManagementCubit, QueueManagementState>(
        'does not trigger auto no-show when entry is serving',
        build: () {
          when(() => mockWatchDailyQueue.call(orgId: testOrgId, date: testDate))
              .thenAnswer((_) => Stream.value(Success(createTestSnapshot(
                    current: createTestQueueEntry(
                      appointmentId: testAppointmentId,
                      status: AppointmentStatus.serving,
                      automationState: QueueAutomationState.serving,
                    ),
                  ))));
          when(() => mockRepository.watchAppointmentsByDate(
                orgId: testOrgId,
                date: testDate,
              )).thenAnswer((_) => Stream.value([]));

          return cubit;
        },
        act: (cubit) async {
          cubit.watchQueue(orgId: testOrgId, date: testDate);
          await Future.delayed(const Duration(milliseconds: 100)); // Allow processing
        },
        expect: () => [
          isA<QueueManagementLoading>(),
          isA<QueueManagementLoaded>(),
        ],
        verify: (cubit) {
          verifyNever(() => mockRepository.markOverdueNoShow(
                orgId: any(named: 'orgId'),
                date: any(named: 'date'),
                appointmentId: any(named: 'appointmentId'),
              ));
        },
      );

      blocTest<QueueManagementCubit, QueueManagementState>(
        'prevents duplicate auto no-show triggers for same appointment',
        build: () {
          final overdueEntry = createTestQueueEntry(
            appointmentId: testAppointmentId,
            status: AppointmentStatus.inQueue,
            automationState: QueueAutomationState.overdue,
          );

          when(() => mockWatchDailyQueue.call(orgId: testOrgId, date: testDate))
              .thenAnswer((_) => Stream.periodic(
                    const Duration(milliseconds: 50),
                    (_) => Success(createTestSnapshot(current: overdueEntry)),
                  ).take(3));
          when(() => mockRepository.watchAppointmentsByDate(
                orgId: testOrgId,
                date: testDate,
              )).thenAnswer((_) => Stream.value([]));
          when(() => mockRepository.markOverdueNoShow(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).thenAnswer((_) async {
            // Simulate slow network operation
            await Future.delayed(const Duration(milliseconds: 200));
            return const Success(null);
          });

          return cubit;
        },
        act: (cubit) async {
          cubit.watchQueue(orgId: testOrgId, date: testDate);
          await Future.delayed(const Duration(milliseconds: 300)); // Wait for all operations
        },
        expect: () => [
          isA<QueueManagementLoading>(),
          isA<QueueManagementLoaded>(),
          isA<QueueManagementLoaded>(),
          isA<QueueManagementLoaded>(),
          isA<QueueManagementLoaded>(),
        ],
        verify: (cubit) {
          // Should only be called once despite multiple emissions
          verify(() => mockRepository.markOverdueNoShow(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).called(1);
        },
      );
    });

    group('manual queue actions', () {
      blocTest<QueueManagementCubit, QueueManagementState>(
        'next (advance) queue successfully',
        build: () {
          when(() => mockAdvanceQueue.call(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).thenAnswer((_) async => const Success(null));
          return cubit;
        },
        seed: () => QueueManagementLoaded(
          snapshot: createTestSnapshot(),
          evaluatedAt: DateTime.now(),
        ),
        act: (cubit) => cubit.next(
          orgId: testOrgId,
          date: testDate,
          appointmentId: testAppointmentId,
        ),
        expect: () => [
          isA<QueueManagementActionInFlight>(),
          isA<QueueManagementLoaded>(),
        ],
        verify: (cubit) {
          verify(() => mockAdvanceQueue.call(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).called(1);
        },
      );

      blocTest<QueueManagementCubit, QueueManagementState>(
        'skip queue entry successfully',
        build: () {
          when(() => mockSkipQueueEntry.call(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).thenAnswer((_) async => const Success(null));
          return cubit;
        },
        seed: () => QueueManagementLoaded(
          snapshot: createTestSnapshot(),
          evaluatedAt: DateTime.now(),
        ),
        act: (cubit) => cubit.skip(
          orgId: testOrgId,
          date: testDate,
          appointmentId: testAppointmentId,
        ),
        expect: () => [
          isA<QueueManagementActionInFlight>(),
          isA<QueueManagementLoaded>(),
        ],
        verify: (cubit) {
          verify(() => mockSkipQueueEntry.call(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).called(1);
        },
      );

      blocTest<QueueManagementCubit, QueueManagementState>(
        'mark no show successfully',
        build: () {
          when(() => mockMarkNoShow.call(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).thenAnswer((_) async => const Success(null));
          return cubit;
        },
        seed: () => QueueManagementLoaded(
          snapshot: createTestSnapshot(),
          evaluatedAt: DateTime.now(),
        ),
        act: (cubit) => cubit.markNoShow(
          orgId: testOrgId,
          date: testDate,
          appointmentId: testAppointmentId,
        ),
        expect: () => [
          isA<QueueManagementActionInFlight>(),
          isA<QueueManagementLoaded>(),
        ],
        verify: (cubit) {
          verify(() => mockMarkNoShow.call(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).called(1);
        },
      );

      blocTest<QueueManagementCubit, QueueManagementState>(
        'rejoin skipped entry successfully',
        build: () {
          when(() => mockRejoinSkipped.call(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).thenAnswer((_) async => const Success(null));
          return cubit;
        },
        seed: () => QueueManagementLoaded(
          snapshot: createTestSnapshot(),
          evaluatedAt: DateTime.now(),
        ),
        act: (cubit) => cubit.rejoin(
          orgId: testOrgId,
          date: testDate,
          appointmentId: testAppointmentId,
        ),
        expect: () => [
          isA<QueueManagementActionInFlight>(),
          isA<QueueManagementLoaded>(),
        ],
        verify: (cubit) {
          verify(() => mockRejoinSkipped.call(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).called(1);
        },
      );

      blocTest<QueueManagementCubit, QueueManagementState>(
        'handles action failure and emits error state',
        build: () {
          when(() => mockAdvanceQueue.call(
                orgId: testOrgId,
                date: testDate,
                appointmentId: testAppointmentId,
              )).thenAnswer((_) async => const Failure(
                DatabaseException('Action failed')));
          return cubit;
        },
        seed: () => QueueManagementLoaded(
          snapshot: createTestSnapshot(),
          evaluatedAt: DateTime.now(),
        ),
        act: (cubit) => cubit.next(
          orgId: testOrgId,
          date: testDate,
          appointmentId: testAppointmentId,
        ),
        expect: () => [
          isA<QueueManagementActionInFlight>(),
          isA<QueueManagementError>(),
        ],
      );
    });

    group('generate queue', () {
      blocTest<QueueManagementCubit, QueueManagementState>(
        'generate queue successfully',
        build: () {
          when(() => mockGenerateQueue.call(
                orgId: testOrgId,
                date: testDate,
              )).thenAnswer((_) async => const Success(null));
          return cubit;
        },
        act: (cubit) => cubit.generateQueue(orgId: testOrgId, date: testDate),
        expect: () => [
          isA<QueueManagementLoading>(),
        ],
        verify: (cubit) {
          verify(() => mockGenerateQueue.call(
                orgId: testOrgId,
                date: testDate,
              )).called(1);
        },
      );

      blocTest<QueueManagementCubit, QueueManagementState>(
        'handle generate queue failure',
        build: () {
          when(() => mockGenerateQueue.call(
                orgId: testOrgId,
                date: testDate,
              )).thenAnswer((_) async => const Failure(
                DatabaseException('Generation failed')));
          return cubit;
        },
        act: (cubit) => cubit.generateQueue(orgId: testOrgId, date: testDate),
        expect: () => [
          isA<QueueManagementLoading>(),
          isA<QueueManagementError>(),
        ],
      );
    });
  });
}