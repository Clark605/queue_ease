// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/admin/organization_management/data/datasources/admin_organization_datasource.dart'
    as _i826;
import '../../features/admin/organization_management/data/repositories/admin_organization_repository_impl.dart'
    as _i397;
import '../../features/admin/organization_management/domain/repositories/admin_organization_repository.dart'
    as _i960;
import '../../features/admin/organization_management/presentation/cubit/organization_cubit.dart'
    as _i785;
import '../../features/admin/queue_management/data/datasources/admin_queue_datasource.dart'
    as _i702;
import '../../features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart'
    as _i454;
import '../../features/admin/queue_management/domain/repositories/admin_appointment_repository.dart'
    as _i761;
import '../../features/admin/queue_management/domain/use_cases/advance_queue_use_case.dart'
    as _i244;
import '../../features/admin/queue_management/domain/use_cases/generate_daily_queue_use_case.dart'
    as _i175;
import '../../features/admin/queue_management/domain/use_cases/mark_no_show_use_case.dart'
    as _i174;
import '../../features/admin/queue_management/domain/use_cases/rejoin_skipped_use_case.dart'
    as _i241;
import '../../features/admin/queue_management/domain/use_cases/skip_queue_entry_use_case.dart'
    as _i388;
import '../../features/admin/queue_management/domain/use_cases/start_serving_use_case.dart'
    as _i95;
import '../../features/admin/queue_management/domain/use_cases/watch_daily_queue_use_case.dart'
    as _i774;
import '../../features/admin/queue_management/presentation/cubit/queue_management_cubit.dart'
    as _i463;
import '../../features/admin/service_management/data/datasources/admin_service_datasource.dart'
    as _i380;
import '../../features/admin/service_management/data/repositories/admin_service_repository_impl.dart'
    as _i712;
import '../../features/admin/service_management/domain/repositories/admin_service_repository.dart'
    as _i557;
import '../../features/admin/service_management/presentation/cubit/service_cubit.dart'
    as _i984;
import '../../features/admin/share_access/presentation/cubit/share_access_cubit.dart'
    as _i173;
import '../../features/admin/tutorial/presentation/cubit/tutorial_cubit.dart'
    as _i1046;
import '../../features/admin/working_hours_management/data/datasources/admin_working_hours_datasource.dart'
    as _i85;
import '../../features/admin/working_hours_management/data/repositories/admin_working_hours_repository_impl.dart'
    as _i470;
import '../../features/admin/working_hours_management/domain/repositories/admin_working_hours_repository.dart'
    as _i441;
import '../../features/admin/working_hours_management/presentation/cubit/working_hours_cubit.dart'
    as _i132;
import '../../features/authentication/data/datasources/firebase_auth_datasource.dart'
    as _i529;
import '../../features/authentication/data/datasources/firestore_user_datasource.dart'
    as _i1039;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i317;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i742;
import '../../features/authentication/presentation/cubit/auth_cubit.dart'
    as _i678;
import '../../features/customer/access_portal/domain/use_cases/parse_access_url_use_case.dart'
    as _i1012;
import '../../features/customer/access_portal/presentation/cubit/access_portal_cubit.dart'
    as _i454;
import '../../features/customer/booking/data/datasources/customer_appointment_datasource.dart'
    as _i371;
import '../../features/customer/booking/data/datasources/customer_organization_datasource.dart'
    as _i857;
import '../../features/customer/booking/data/datasources/customer_service_datasource.dart'
    as _i527;
import '../../features/customer/booking/data/datasources/customer_working_hours_datasource.dart'
    as _i1029;
import '../../features/customer/booking/data/repositories/customer_appointment_repository_impl.dart'
    as _i868;
import '../../features/customer/booking/data/repositories/customer_organization_repository_impl.dart'
    as _i740;
import '../../features/customer/booking/data/repositories/customer_service_repository_impl.dart'
    as _i255;
import '../../features/customer/booking/data/repositories/customer_working_hours_repository_impl.dart'
    as _i587;
import '../../features/customer/booking/domain/repositories/customer_appointment_repository.dart'
    as _i622;
import '../../features/customer/booking/domain/repositories/customer_organization_repository.dart'
    as _i636;
import '../../features/customer/booking/domain/repositories/customer_service_repository.dart'
    as _i948;
import '../../features/customer/booking/domain/repositories/customer_working_hours_repository.dart'
    as _i492;
import '../../features/customer/booking/domain/use_cases/calculate_available_slots_use_case.dart'
    as _i499;
import '../../features/customer/booking/domain/use_cases/create_booking_use_case.dart'
    as _i1040;
import '../../features/customer/booking/domain/use_cases/get_active_services_use_case.dart'
    as _i48;
import '../../features/customer/booking/domain/use_cases/get_organization_by_slug_use_case.dart'
    as _i952;
import '../../features/customer/booking/presentation/cubit/booking_form_cubit.dart'
    as _i651;
import '../../features/customer/booking/presentation/cubit/organization_landing_cubit.dart'
    as _i912;
import '../../features/customer/booking/presentation/cubit/service_selection_cubit.dart'
    as _i986;
import '../../features/customer/booking/presentation/cubit/slot_picker_cubit.dart'
    as _i968;
import '../../features/customer/entry/domain/use_cases/calculate_wait_time_use_case.dart'
    as _i451;
import '../../features/customer/entry/domain/use_cases/watch_customer_dashboard_use_case.dart'
    as _i979;
import '../../features/customer/entry/domain/use_cases/watch_customer_queue_status_use_case.dart'
    as _i263;
import '../../features/customer/entry/presentation/cubit/customer_dashboard_cubit.dart'
    as _i424;
import '../../features/customer/entry/presentation/cubit/customer_queue_status_cubit.dart'
    as _i28;
import '../config/auth_module.dart' as _i322;
import '../config/config_module.dart' as _i557;
import '../config/flavor_config.dart' as _i636;
import '../services/onboarding_service.dart' as _i854;
import '../services/user_session_service.dart' as _i343;
import '../utils/app_logger.dart' as _i924;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final authModule = _$AuthModule();
    final configModule = _$ConfigModule();
    gh.factory<_i451.CalculateWaitTimeUseCase>(
      () => const _i451.CalculateWaitTimeUseCase(),
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => authModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => authModule.firestore);
    gh.lazySingleton<_i116.GoogleSignIn>(() => authModule.googleSignIn);
    gh.lazySingleton<_i636.FlavorConfig>(() => configModule.config);
    gh.lazySingleton<_i1012.ParseAccessUrlUseCase>(
      () => _i1012.ParseAccessUrlUseCase(),
    );
    gh.singleton<_i924.AppLogger>(
      () => _i924.AppLogger(gh<_i636.FlavorConfig>()),
    );
    gh.lazySingleton<_i854.OnboardingService>(
      () => _i854.OnboardingService(gh<_i924.AppLogger>()),
    );
    gh.lazySingleton<_i343.UserSessionService>(
      () => _i343.UserSessionService(gh<_i924.AppLogger>()),
    );
    gh.factory<_i173.ShareAccessCubit>(
      () => _i173.ShareAccessCubit(gh<_i924.AppLogger>()),
    );
    gh.lazySingleton<_i826.AdminOrganizationDatasource>(
      () => _i826.AdminOrganizationDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i702.AdminQueueDatasource>(
      () => _i702.AdminQueueDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i380.AdminServiceDatasource>(
      () => _i380.AdminServiceDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i85.AdminWorkingHoursDatasource>(
      () => _i85.AdminWorkingHoursDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i1039.FirestoreUserDatasource>(
      () => _i1039.FirestoreUserDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i371.CustomerAppointmentDatasource>(
      () => _i371.CustomerAppointmentDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i857.CustomerOrganizationDatasource>(
      () => _i857.CustomerOrganizationDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i527.CustomerServiceDatasource>(
      () => _i527.CustomerServiceDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i1029.CustomerWorkingHoursDatasource>(
      () => _i1029.CustomerWorkingHoursDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i529.FirebaseAuthDatasource>(
      () => _i529.FirebaseAuthDatasource(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i761.AdminAppointmentRepository>(
      () => _i454.AdminQueueRepositoryImpl(
        gh<_i702.AdminQueueDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i244.AdvanceQueueUseCase>(
      () => _i244.AdvanceQueueUseCase(
        gh<_i761.AdminAppointmentRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i175.GenerateDailyQueueUseCase>(
      () => _i175.GenerateDailyQueueUseCase(
        gh<_i761.AdminAppointmentRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i174.MarkNoShowUseCase>(
      () => _i174.MarkNoShowUseCase(
        gh<_i761.AdminAppointmentRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i241.RejoinSkippedUseCase>(
      () => _i241.RejoinSkippedUseCase(
        gh<_i761.AdminAppointmentRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i388.SkipQueueEntryUseCase>(
      () => _i388.SkipQueueEntryUseCase(
        gh<_i761.AdminAppointmentRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i95.StartServingUseCase>(
      () => _i95.StartServingUseCase(
        gh<_i761.AdminAppointmentRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i774.WatchDailyQueueUseCase>(
      () => _i774.WatchDailyQueueUseCase(
        gh<_i761.AdminAppointmentRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i1046.TutorialCubit>(
      () => _i1046.TutorialCubit(
        gh<_i1039.FirestoreUserDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i948.CustomerServiceRepository>(
      () => _i255.CustomerServiceRepositoryImpl(
        gh<_i527.CustomerServiceDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i557.AdminServiceRepository>(
      () => _i712.AdminServiceRepositoryImpl(
        gh<_i380.AdminServiceDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i454.AccessPortalCubit>(
      () => _i454.AccessPortalCubit(gh<_i1012.ParseAccessUrlUseCase>()),
    );
    gh.lazySingleton<_i636.CustomerOrganizationRepository>(
      () => _i740.CustomerOrganizationRepositoryImpl(
        gh<_i857.CustomerOrganizationDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i622.CustomerAppointmentRepository>(
      () => _i868.CustomerAppointmentRepositoryImpl(
        gh<_i371.CustomerAppointmentDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i984.ServiceCubit>(
      () => _i984.ServiceCubit(
        gh<_i557.AdminServiceRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i952.GetOrganizationBySlugUseCase>(
      () => _i952.GetOrganizationBySlugUseCase(
        gh<_i636.CustomerOrganizationRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i463.QueueManagementCubit>(
      () => _i463.QueueManagementCubit(
        gh<_i761.AdminAppointmentRepository>(),
        gh<_i175.GenerateDailyQueueUseCase>(),
        gh<_i774.WatchDailyQueueUseCase>(),
        gh<_i244.AdvanceQueueUseCase>(),
        gh<_i388.SkipQueueEntryUseCase>(),
        gh<_i174.MarkNoShowUseCase>(),
        gh<_i241.RejoinSkippedUseCase>(),
        gh<_i95.StartServingUseCase>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i960.AdminOrganizationRepository>(
      () => _i397.AdminOrganizationRepositoryImpl(
        gh<_i826.AdminOrganizationDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i492.CustomerWorkingHoursRepository>(
      () => _i587.CustomerWorkingHoursRepositoryImpl(
        gh<_i1029.CustomerWorkingHoursDatasource>(),
      ),
    );
    gh.lazySingleton<_i499.CalculateAvailableSlotsUseCase>(
      () => _i499.CalculateAvailableSlotsUseCase(
        gh<_i622.CustomerAppointmentRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i1040.CreateBookingUseCase>(
      () => _i1040.CreateBookingUseCase(
        gh<_i622.CustomerAppointmentRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i441.AdminWorkingHoursRepository>(
      () => _i470.AdminWorkingHoursRepositoryImpl(
        gh<_i85.AdminWorkingHoursDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i968.SlotPickerCubit>(
      () => _i968.SlotPickerCubit(
        gh<_i499.CalculateAvailableSlotsUseCase>(),
        gh<_i492.CustomerWorkingHoursRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i912.OrganizationLandingCubit>(
      () => _i912.OrganizationLandingCubit(
        gh<_i952.GetOrganizationBySlugUseCase>(),
        gh<_i492.CustomerWorkingHoursRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i785.OrganizationCubit>(
      () => _i785.OrganizationCubit(
        gh<_i960.AdminOrganizationRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i651.BookingFormCubit>(
      () => _i651.BookingFormCubit(
        gh<_i1040.CreateBookingUseCase>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i132.WorkingHoursCubit>(
      () => _i132.WorkingHoursCubit(
        gh<_i441.AdminWorkingHoursRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i48.GetActiveServicesUseCase>(
      () => _i48.GetActiveServicesUseCase(
        gh<_i948.CustomerServiceRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i263.WatchCustomerQueueStatusUseCase>(
      () => _i263.WatchCustomerQueueStatusUseCase(
        gh<_i622.CustomerAppointmentRepository>(),
        gh<_i451.CalculateWaitTimeUseCase>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i986.ServiceSelectionCubit>(
      () => _i986.ServiceSelectionCubit(
        gh<_i48.GetActiveServicesUseCase>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i979.WatchCustomerDashboardUseCase>(
      () => _i979.WatchCustomerDashboardUseCase(
        gh<_i622.CustomerAppointmentRepository>(),
        gh<_i263.WatchCustomerQueueStatusUseCase>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i742.AuthRepository>(
      () => _i317.AuthRepositoryImpl(
        gh<_i529.FirebaseAuthDatasource>(),
        gh<_i1039.FirestoreUserDatasource>(),
        gh<_i343.UserSessionService>(),
        gh<_i960.AdminOrganizationRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i28.CustomerQueueStatusCubit>(
      () => _i28.CustomerQueueStatusCubit(
        gh<_i263.WatchCustomerQueueStatusUseCase>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i424.CustomerDashboardCubit>(
      () => _i424.CustomerDashboardCubit(
        gh<_i979.WatchCustomerDashboardUseCase>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i678.AuthCubit>(
      () => _i678.AuthCubit(gh<_i742.AuthRepository>(), gh<_i924.AppLogger>()),
    );
    return this;
  }
}

class _$AuthModule extends _i322.AuthModule {}

class _$ConfigModule extends _i557.ConfigModule {}
