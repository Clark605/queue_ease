import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/customer/booking/domain/use_cases/get_organization_by_slug_use_case.dart';
import 'package:queue_ease/features/customer/booking/presentation/cubit/organization_landing_cubit.dart';
import 'package:queue_ease/features/customer/booking/presentation/cubit/organization_landing_state.dart';
import 'package:queue_ease/features/shared_domain/entities/organization_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';
import 'package:queue_ease/features/customer/booking/domain/repositories/customer_working_hours_repository.dart';

class MockGetOrganizationBySlugUseCase extends Mock
    implements GetOrganizationBySlugUseCase {}

class MockWorkingHoursRepository extends Mock
    implements CustomerWorkingHoursRepository {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late OrganizationLandingCubit cubit;
  late MockGetOrganizationBySlugUseCase mockGetOrg;
  late MockWorkingHoursRepository mockWHRepo;
  late MockAppLogger mockLogger;

  setUp(() {
    mockGetOrg = MockGetOrganizationBySlugUseCase();
    mockWHRepo = MockWorkingHoursRepository();
    mockLogger = MockAppLogger();
    when(() => mockLogger.debug(any())).thenReturn(null);
    when(() => mockLogger.warning(any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);

    cubit = OrganizationLandingCubit(mockGetOrg, mockWHRepo, mockLogger);
  });

  tearDown(() async {
    await cubit.close();
  });

  test(
    'emits OrganizationLandingLoaded when working hours indicate open',
    () async {
      final org = OrganizationEntity(
        id: 'org1',
        name: 'Org',
        adminUid: 'admin1',
        bookingLinkSlug: 'o',
        isOpen: true,
        createdAt: DateTime.now(),
      );

      // Build a working-hours entry that surrounds now
      final now = DateTime.now();
      final hourBefore = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour - 1,
        now.minute,
      );
      final hourAfter = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour + 1,
        now.minute,
      );

      final wh = WorkingHoursEntity(
        orgId: org.id,
        dayOfWeek: now.weekday - 1,
        isOpen: true,
        openTime:
            '${hourBefore.hour.toString().padLeft(2, '0')}:${hourBefore.minute.toString().padLeft(2, '0')}',
        closeTime:
            '${hourAfter.hour.toString().padLeft(2, '0')}:${hourAfter.minute.toString().padLeft(2, '0')}',
      );

      when(
        () => mockGetOrg.call(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockGetOrg.call('slug1'),
      ).thenAnswer((_) async => Success(org));
      when(
        () => mockWHRepo.watchWorkingHours(org.id),
      ).thenAnswer((_) => Stream.value([wh]));

      final future = expectLater(
        cubit.stream,
        emitsThrough(isA<OrganizationLandingLoaded>()),
      );

      await cubit.loadOrganization('slug1');

      await future;
    },
  );

  test(
    'emits OrganizationLandingLoaded with isCurrentlyOpen=false when closed',
    () async {
      final org = OrganizationEntity(
        id: 'org2',
        name: 'Org2',
        adminUid: 'admin2',
        bookingLinkSlug: 'o2',
        isOpen: true,
        createdAt: DateTime.now(),
      );

      final now = DateTime.now();
      final before = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour - 5,
        now.minute,
      );
      final earlier = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour - 3,
        now.minute,
      );

      final wh = WorkingHoursEntity(
        orgId: org.id,
        dayOfWeek: now.weekday - 1,
        isOpen: true,
        openTime:
            '${before.hour.toString().padLeft(2, '0')}:${before.minute.toString().padLeft(2, '0')}',
        closeTime:
            '${earlier.hour.toString().padLeft(2, '0')}:${earlier.minute.toString().padLeft(2, '0')}',
      );

      when(
        () => mockGetOrg.call('slug2'),
      ).thenAnswer((_) async => Success(org));
      when(
        () => mockWHRepo.watchWorkingHours(org.id),
      ).thenAnswer((_) => Stream.value([wh]));

      final future = expectLater(
        cubit.stream,
        emitsThrough(
          predicate(
            (state) =>
                state is OrganizationLandingLoaded &&
                state.isCurrentlyOpen == false,
          ),
        ),
      );

      await cubit.loadOrganization('slug2');

      await future;
    },
  );
}
