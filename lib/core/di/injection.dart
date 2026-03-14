import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

/// Dependency injection configuration using injectable + get_it.
///
/// All repositories follow the Role-Based Feature Repositories pattern (ADR-001):
///   - Admin repositories live in lib/features/admin/
///   - Customer repositories live in lib/features/customer/booking/
///   - Shared entities live in lib/features/shared_domain/
///
/// Run `flutter pub run build_runner build --delete-conflicting-outputs` after
/// adding @LazySingleton or @Injectable annotations to new repositories.
@InjectableInit(preferRelativeImports: true)
void configureDependencies({String? environment}) =>
    getIt.init(environment: environment);
