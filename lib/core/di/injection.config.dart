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

import '../../../admin/organization/presentation/cubit/organization_cubit.dart'
    as _i616;
import '../../../admin/services/presentation/cubit/service_cubit.dart' as _i714;
import '../../../admin/tutorial/presentation/cubit/tutorial_cubit.dart'
    as _i790;
import '../../../admin/working_hours/presentation/cubit/working_hours_cubit.dart'
    as _i567;
import '../../../shared/auth/data/datasources/firebase_auth_datasource.dart'
    as _i480;
import '../../../shared/auth/data/datasources/firestore_user_datasource.dart'
    as _i500;
import '../../../shared/auth/data/repositories/auth_repository_impl.dart'
    as _i161;
import '../../../shared/auth/domain/repositories/auth_repository.dart' as _i489;
import '../../../shared/auth/presentation/cubit/auth_cubit.dart' as _i928;
import '../../../shared/organization/data/datasources/firestore_organization_datasource.dart'
    as _i681;
import '../../../shared/organization/data/datasources/firestore_service_datasource.dart'
    as _i251;
import '../../../shared/organization/data/datasources/firestore_working_hours_datasource.dart'
    as _i985;
import '../../../shared/organization/data/repositories/organization_repository_impl.dart'
    as _i503;
import '../../../shared/organization/data/repositories/service_repository_impl.dart'
    as _i309;
import '../../../shared/organization/data/repositories/working_hours_repository_impl.dart'
    as _i219;
import '../../../shared/organization/domain/repositories/organization_repository.dart'
    as _i506;
import '../../../shared/organization/domain/repositories/service_repository.dart'
    as _i973;
import '../../../shared/organization/domain/repositories/working_hours_repository.dart'
    as _i449;
import '../../config/auth_module.dart' as _i972;
import '../../config/config_module.dart' as _i580;
import '../../config/flavor_config.dart' as _i722;
import '../../services/onboarding_service.dart' as _i461;
import '../../services/user_session_service.dart' as _i925;
import '../../utils/app_logger.dart' as _i1021;

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
    gh.lazySingleton<_i722.FlavorConfig>(() => configModule.config);
    gh.singleton<_i1021.AppLogger>(
      () => _i1021.AppLogger(gh<_i722.FlavorConfig>()),
    );
    gh.lazySingleton<_i461.OnboardingService>(
      () => _i461.OnboardingService(gh<_i1021.AppLogger>()),
    );
    gh.lazySingleton<_i925.UserSessionService>(
      () => _i925.UserSessionService(gh<_i1021.AppLogger>()),
    );
    gh.lazySingleton<_i500.FirestoreUserDatasource>(
      () => _i500.FirestoreUserDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i681.FirestoreOrganizationDatasource>(
      () => _i681.FirestoreOrganizationDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i251.FirestoreServiceDatasource>(
      () => _i251.FirestoreServiceDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i985.FirestoreWorkingHoursDatasource>(
      () => _i985.FirestoreWorkingHoursDatasource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i480.FirebaseAuthDatasource>(
      () => _i480.FirebaseAuthDatasource(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i506.OrganizationRepository>(
      () => _i503.OrganizationRepositoryImpl(
        gh<_i681.FirestoreOrganizationDatasource>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i489.AuthRepository>(
      () => _i161.AuthRepositoryImpl(
        gh<_i480.FirebaseAuthDatasource>(),
        gh<_i500.FirestoreUserDatasource>(),
        gh<_i925.UserSessionService>(),
        gh<_i506.OrganizationRepository>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.factory<_i790.TutorialCubit>(
      () => _i790.TutorialCubit(
        gh<_i500.FirestoreUserDatasource>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i973.ServiceRepository>(
      () => _i309.ServiceRepositoryImpl(
        gh<_i251.FirestoreServiceDatasource>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.factory<_i616.OrganizationCubit>(
      () => _i616.OrganizationCubit(
        gh<_i506.OrganizationRepository>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i449.WorkingHoursRepository>(
      () => _i219.WorkingHoursRepositoryImpl(
        gh<_i985.FirestoreWorkingHoursDatasource>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.factory<_i714.ServiceCubit>(
      () => _i714.ServiceCubit(
        gh<_i973.ServiceRepository>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i928.AuthCubit>(
      () => _i928.AuthCubit(gh<_i489.AuthRepository>(), gh<_i1021.AppLogger>()),
    );
    gh.factory<_i567.WorkingHoursCubit>(
      () => _i567.WorkingHoursCubit(
        gh<_i449.WorkingHoursRepository>(),
        gh<_i1021.AppLogger>(),
      ),
    );
    return this;
  }
}

class _$AuthModule extends _i972.AuthModule {}

class _$ConfigModule extends _i580.ConfigModule {}
