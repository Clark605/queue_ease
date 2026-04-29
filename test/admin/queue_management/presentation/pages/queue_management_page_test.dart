import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/admin/queue_management/domain/repositories/admin_appointment_repository.dart'
    show AdminAppointmentRepository, AdminQueueSnapshot;
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/advance_queue_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/generate_daily_queue_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/mark_no_show_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/rejoin_skipped_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/skip_queue_entry_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/start_serving_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/domain/use_cases/watch_daily_queue_use_case.dart';
import 'package:queue_ease/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart';
import 'package:queue_ease/features/admin/queue_management/presentation/cubit/queue_management_state.dart';
import 'package:queue_ease/features/admin/queue_management/presentation/pages/queue_management_page.dart';
import 'package:queue_ease/features/authentication/domain/entities/user_entity.dart';
import 'package:queue_ease/features/authentication/domain/entities/user_role.dart';
import 'package:queue_ease/features/authentication/domain/repositories/auth_repository.dart';
import 'package:queue_ease/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:queue_ease/features/authentication/presentation/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

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

class MockStartServingUseCase extends Mock implements StartServingUseCase {}

class MockAppLogger extends Mock implements AppLogger {}

class TestAuthCubit extends AuthCubit {
  TestAuthCubit(super.authRepository, super.logger);

  void setStateForTest(AuthState newState) => emit(newState);
}

class TestQueueManagementCubit extends QueueManagementCubit {
  TestQueueManagementCubit(
    super.repository,
    super.generateQueue,
    super.watchDailyQueue,
    super.advanceQueue,
    super.skipQueueEntry,
    super.markNoShow,
    super.rejoinSkipped,
    super.startServingUseCase,
    super.logger,
  );

  void setStateForTest(QueueManagementState newState) => emit(newState);
}

void main() {
  group('QueueManagementPage', () {
    late TestAuthCubit authCubit;
    late TestQueueManagementCubit queueCubit;

    setUp(() {
      authCubit = TestAuthCubit(MockAuthRepository(), MockAppLogger());
      queueCubit = TestQueueManagementCubit(
        MockAdminAppointmentRepository(),
        MockGenerateDailyQueueUseCase(),
        MockWatchDailyQueueUseCase(),
        MockAdvanceQueueUseCase(),
        MockSkipQueueEntryUseCase(),
        MockMarkNoShowUseCase(),
        MockRejoinSkippedUseCase(),
        MockStartServingUseCase(),
        MockAppLogger(),
      );
    });

    tearDown(() async {
      await authCubit.close();
      await queueCubit.close();
    });

    testWidgets('does not show queue error snackbar while signing out', (
      tester,
    ) async {
      final authenticatedUser = const UserEntity(
        uid: 'admin-1',
        email: 'admin@example.com',
        role: UserRole.admin,
        organizationId: 'org-1',
      );

      authCubit.setStateForTest(Authenticated(authenticatedUser));
      queueCubit.setStateForTest(
        QueueManagementLoaded(
          snapshot: AdminQueueSnapshot(
            queueDate: DateTime(2026, 4, 29),
            current: null,
            waiting: [],
          ),
          evaluatedAt: DateTime(2026, 4, 29),
        ),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<QueueManagementCubit>.value(value: queueCubit),
          ],
          child: const MaterialApp(home: QueueManagementPage()),
        ),
      );

      expect(find.text('Queue Management'), findsOneWidget);

      authCubit.setStateForTest(const AuthLoading());
      await tester.pump();

      expect(find.text('Queue Management'), findsNothing);

      queueCubit.setStateForTest(
        const QueueManagementError(
          message: 'Unable to load queue data right now. Please try again.',
        ),
      );
      await tester.pump();

      expect(
        find.text('Unable to load queue data right now. Please try again.'),
        findsNothing,
      );
    });
  });
}
