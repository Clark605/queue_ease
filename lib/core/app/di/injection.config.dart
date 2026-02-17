// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../config/config_module.dart' as _i580;
import '../../config/flavor_config.dart' as _i722;
import '../../services/onboarding_service.dart' as _i461;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final configModule = _$ConfigModule();
    gh.lazySingleton<_i722.FlavorConfig>(() => configModule.config);
    gh.lazySingleton<_i461.OnboardingService>(() => _i461.OnboardingService());
    return this;
  }
}

class _$ConfigModule extends _i580.ConfigModule {}
