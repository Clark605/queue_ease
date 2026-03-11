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

import '../../admin/organization/data/datasources/admin_organization_datasource.dart'
    as _i391;
import '../../admin/organization/data/repositories/admin_organization_repository_impl.dart'
    as _i1012;
import '../../admin/organization/domain/repositories/admin_organization_repository.dart'
    as _i254;
import '../../admin/organization/presentation/cubit/organization_cubit.dart'
    as _i549;
import '../../admin/services/data/datasources/admin_service_datasource.dart'
    as _i853;
import '../../admin/services/data/repositories/admin_service_repository_impl.dart'
    as _i695;
import '../../admin/services/domain/repositories/admin_service_repository.dart'
    as _i333;
import '../../admin/services/presentation/cubit/service_cubit.dart' as _i214;
import '../../admin/share_access/presentation/cubit/share_access_cubit.dart'
    as _i792;
import '../../admin/tutorial/presentation/cubit/tutorial_cubit.dart' as _i960;
import '../../admin/working_hours/data/datasources/admin_working_hours_datasource.dart'
    as _i149;
import '../../admin/working_hours/data/repositories/admin_working_hours_repository_impl.dart'
    as _i1051;
import '../../admin/working_hours/domain/repositories/admin_working_hours_repository.dart'
    as _i8;
import '../../admin/working_hours/presentation/cubit/working_hours_cubit.dart'
    as _i991;
import '../../shared/auth/data/datasources/firebase_auth_datasource.dart'
    as _i992;
import '../../shared/auth/data/datasources/firestore_user_datasource.dart'
    as _i241;
import '../../shared/auth/data/repositories/auth_repository_impl.dart' as _i607;
import '../../shared/auth/domain/repositories/auth_repository.dart' as _i61;
import '../../shared/auth/presentation/cubit/auth_cubit.dart' as _i728;
import '../../shared/organization/data/datasources/firestore_organization_datasource.dart'
    as _i543;
import '../../shared/organization/data/datasources/firestore_service_datasource.dart'
    as _i41;
import '../../shared/organization/data/datasources/firestore_working_hours_datasource.dart'
    as _i644;
import '../../shared/organization/data/repositories/organization_repository_impl.dart'
    as _i220;
import '../../shared/organization/data/repositories/service_repository_impl.dart'
    as _i423;
import '../../shared/organization/data/repositories/working_hours_repository_impl.dart'
    as _i590;
import '../../shared/organization/domain/repositories/organization_repository.dart'
    as _i1058;
import '../../shared/organization/domain/repositories/service_repository.dart'
    as _i709;
import '../../shared/organization/domain/repositories/working_hours_repository.dart'
    as _i57;
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
    gh.lazySingleton<_i59.FirebaseAuth>(() => authModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => authModule.firestore);
    gh.lazySingleton<_i116.GoogleSignIn>(() => authModule.googleSignIn);
    gh.lazySingleton<_i636.FlavorConfig>(() => configModule.config);
    gh.singleton<_i924.AppLogger>(
      () => _i924.AppLogger(gh<_i636.FlavorConfig>()),
    );
    gh.lazySingleton<_i854.OnboardingService>(
      () => _i854.OnboardingService(gh<_i924.AppLogger>()),
    );
    gh.lazySingleton<_i343.UserSessionService>(
      () => _i343.UserSessionService(gh<_i924.AppLogger>()),
    );
    gh.factory<_i792.ShareAccessCubit>(
      () => _i792.ShareAccessCubit(gh<_i924.AppLogger>()),
    );
    gh.lazySingleton<_i391.AdminOrganizationDatasource>(
      () => _i391.AdminOrganizationDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i853.AdminServiceDatasource>(
      () => _i853.AdminServiceDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i149.AdminWorkingHoursDatasource>(
      () => _i149.AdminWorkingHoursDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i241.FirestoreUserDatasource>(
      () => _i241.FirestoreUserDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i543.FirestoreOrganizationDatasource>(
      () => _i543.FirestoreOrganizationDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i41.FirestoreServiceDatasource>(
      () => _i41.FirestoreServiceDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i644.FirestoreWorkingHoursDatasource>(
      () => _i644.FirestoreWorkingHoursDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i254.AdminOrganizationRepository>(
      () => _i1012.AdminOrganizationRepositoryImpl(
        gh<_i391.AdminOrganizationDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i992.FirebaseAuthDatasource>(
      () => _i992.FirebaseAuthDatasource(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i333.AdminServiceRepository>(
      () => _i695.AdminServiceRepositoryImpl(
        gh<_i853.AdminServiceDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i8.AdminWorkingHoursRepository>(
      () => _i1051.AdminWorkingHoursRepositoryImpl(
        gh<_i149.AdminWorkingHoursDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i1058.OrganizationRepository>(
      () => _i220.OrganizationRepositoryImpl(
        gh<_i543.FirestoreOrganizationDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i61.AuthRepository>(
      () => _i607.AuthRepositoryImpl(
        gh<_i992.FirebaseAuthDatasource>(),
        gh<_i241.FirestoreUserDatasource>(),
        gh<_i343.UserSessionService>(),
        gh<_i254.AdminOrganizationRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i960.TutorialCubit>(
      () => _i960.TutorialCubit(
        gh<_i241.FirestoreUserDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i549.OrganizationCubit>(
      () => _i549.OrganizationCubit(
        gh<_i1058.OrganizationRepository>(),
        gh<_i254.AdminOrganizationRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i709.ServiceRepository>(
      () => _i423.ServiceRepositoryImpl(
        gh<_i41.FirestoreServiceDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i57.WorkingHoursRepository>(
      () => _i590.WorkingHoursRepositoryImpl(
        gh<_i644.FirestoreWorkingHoursDatasource>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i728.AuthCubit>(
      () => _i728.AuthCubit(gh<_i61.AuthRepository>(), gh<_i924.AppLogger>()),
    );
    gh.factory<_i991.WorkingHoursCubit>(
      () => _i991.WorkingHoursCubit(
        gh<_i57.WorkingHoursRepository>(),
        gh<_i8.AdminWorkingHoursRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    gh.factory<_i214.ServiceCubit>(
      () => _i214.ServiceCubit(
        gh<_i709.ServiceRepository>(),
        gh<_i333.AdminServiceRepository>(),
        gh<_i924.AppLogger>(),
      ),
    );
    return this;
  }
}

class _$AuthModule extends _i322.AuthModule {}

class _$ConfigModule extends _i557.ConfigModule {}
