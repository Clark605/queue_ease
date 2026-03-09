import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../admin/organization/presentation/cubit/organization_cubit.dart';
import '../../../admin/organization/presentation/pages/organization_profile_edit_page.dart';
import '../../../admin/organization/presentation/pages/organization_profile_page.dart';
import '../../../admin/organization/presentation/pages/organization_setup_page.dart';
import '../../../admin/presentation/pages/admin_main_page.dart';
import '../../../admin/services/presentation/cubit/service_cubit.dart';
import '../../../admin/services/presentation/pages/service_form_page.dart';
import '../../../customer/entry/presentation/pages/customer_home_page.dart';
import '../../../shared/auth/domain/entities/user_role.dart';
import '../../../shared/auth/presentation/cubit/auth_cubit.dart';
import '../../../shared/auth/presentation/cubit/auth_state.dart';
import '../../../shared/auth/presentation/pages/login_page.dart';
import '../../../shared/auth/presentation/pages/sign_up_page.dart';
import '../../../shared/onboarding/presentation/pages/onboarding_page.dart';
import '../../../shared/organization/domain/entities/service_entity.dart';
import '../../config/flavor_config.dart';
import '../../services/onboarding_service.dart';
import '../../utils/app_logger.dart';
import '../di/injection.dart';
import 'go_router_refresh_stream.dart';

/// Route paths for the application.
abstract final class Routes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String adminDashboard = '/a/dashboard';
  static const String adminSetup = '/a/setup';
  static const String adminOrgProfile = '/a/org/profile';
  static const String adminOrgEdit = '/a/org/edit';
  static const String adminServices = '/a/services';
  static const String adminServiceForm = '/a/services/form';
  static const String customerHome = '/c/home';

  // Dev-only
  static const String debugLogs = '/debug/logs';
}

/// Application router with RBAC-aware route structure.
///
/// Route convention:
/// - `/a/...` routes are admin-only
/// - `/c/...` routes are customer-only
/// - `/login` is the unauthenticated entry point
/// - `/onboarding` is the first-launch onboarding flow
///
/// [authCubit] must be the GetIt singleton so the router and widget tree share
/// the same state instance.
GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: Routes.onboarding,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    observers: [
      // Only attach the route observer in dev builds so that navigation logs
      // respect the same verbosity rules as the rest of AppLogger.
      if (FlavorConfig.instance.isDev)
        TalkerRouteObserver(getIt<AppLogger>().talker),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final location = state.matchedLocation;
      final isOnboarding = location == Routes.onboarding;
      final isAuthScreen =
          location == Routes.login || location == Routes.signUp;

      final authState = authCubit.state;

      // ── Hold during loading / initial ───────────────────────────────
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // ── Authenticated ───────────────────────────────────────────────
      // Must be checked before the onboarding guard so a returning
      // authenticated user is never bounced to /login.
      if (authState is Authenticated) {
        final user = authState.user;

        // Redirect away from auth / onboarding screens.
        if (isAuthScreen || isOnboarding) {
          if (user.role == UserRole.admin) {
            return user.organizationId == null
                ? Routes.adminSetup
                : Routes.adminDashboard;
          }
          return Routes.customerHome;
        }

        // Missing-org guard: redirect admins without an org to setup screen.
        if (user.role == UserRole.admin &&
            user.organizationId == null &&
            location != Routes.adminSetup) {
          return Routes.adminSetup;
        }
        // Prevent admins who have completed setup from re-visiting setup screen.
        if (user.role == UserRole.admin &&
            user.organizationId != null &&
            location == Routes.adminSetup) {
          return Routes.adminDashboard;
        }

        // Cross-role access guard.
        if (user.role == UserRole.admin && location.startsWith('/c/')) {
          return Routes.adminDashboard;
        }
        if (user.role == UserRole.customer && location.startsWith('/a/')) {
          return Routes.customerHome;
        }

        return null;
      }

      // ── Unauthenticated ─────────────────────────────────────────────
      // Onboarding guard only applies when the user is not authenticated.
      final onboardingService = getIt<OnboardingService>();
      final hasCompletedOnboarding = await onboardingService
          .hasCompletedOnboarding();

      if (hasCompletedOnboarding && isOnboarding) {
        return Routes.login;
      }

      if (authState is Unauthenticated) {
        final isProtected =
            location.startsWith('/a/') || location.startsWith('/c/');
        return isProtected ? Routes.login : null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      // Admin routes
      GoRoute(
        path: Routes.adminDashboard,
        builder: (context, state) => const AdminMainPage(),
      ),
      GoRoute(
        path: Routes.adminSetup,
        builder: (context, state) => const OrganizationSetupPage(),
      ),
      GoRoute(
        path: Routes.adminOrgProfile,
        builder: (context, state) => BlocProvider(
          create: (context) {
            final cubit = getIt<OrganizationCubit>();
            final authState = context.read<AuthCubit>().state;
            if (authState is Authenticated &&
                authState.user.organizationId != null) {
              cubit.watchOrganization(authState.user.organizationId!);
            }
            return cubit;
          },
          child: const OrganizationProfilePage(),
        ),
      ),
      GoRoute(
        path: Routes.adminOrgEdit,
        builder: (context, state) => BlocProvider(
          create: (context) {
            final cubit = getIt<OrganizationCubit>();
            final authState = context.read<AuthCubit>().state;
            if (authState is Authenticated &&
                authState.user.organizationId != null) {
              cubit.watchOrganization(authState.user.organizationId!);
            }
            return cubit;
          },
          child: const OrganizationProfileEditPage(),
        ),
      ),

      GoRoute(
        path: Routes.adminServiceForm,
        builder: (context, state) {
          final service = state.extra as ServiceEntity?;
          return BlocProvider(
            create: (context) {
              final cubit = getIt<ServiceCubit>();
              final authState = context.read<AuthCubit>().state;
              if (authState is Authenticated &&
                  authState.user.organizationId != null) {
                cubit.watchServices(authState.user.organizationId!);
              }
              return cubit;
            },
            child: ServiceFormPage(service: service),
          );
        },
      ),
      // Customer routes
      GoRoute(
        path: Routes.customerHome,
        builder: (context, state) => const CustomerHomePage(),
      ),
      // Dev-only: in-app log viewer
      if (FlavorConfig.instance.isDev)
        GoRoute(
          path: Routes.debugLogs,
          builder: (context, state) => TalkerScreen(
            talker: getIt<AppLogger>().talker,
            appBarTitle: 'App Logs',
          ),
        ),
    ],
  );
}
