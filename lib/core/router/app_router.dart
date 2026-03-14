import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ease/features/admin/organization_management/presentation/cubit/organization_cubit.dart';
import 'package:queue_ease/features/admin/organization_management/presentation/pages/organization_profile_edit_page.dart';
import 'package:queue_ease/features/admin/organization_management/presentation/pages/organization_profile_page.dart';
import 'package:queue_ease/features/admin/organization_management/presentation/pages/organization_setup_page.dart';
import 'package:queue_ease/features/admin/service_management/presentation/pages/service_form_page.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../features/admin/app_section/presentation/pages/admin_main_page.dart';
import '../../features/admin/service_management/presentation/cubit/service_cubit.dart';
import '../../features/admin/share_access/presentation/cubit/share_access_cubit.dart';
import '../../features/admin/share_access/presentation/pages/share_access_page.dart';
import '../../features/admin/working_hours_management/presentation/cubit/working_hours_cubit.dart';
import '../../features/admin/working_hours_management/presentation/pages/working_hours_page.dart';
import '../../features/customer/booking/presentation/cubit/booking_form_cubit.dart';
import '../../features/customer/booking/presentation/cubit/organization_landing_cubit.dart';
import '../../features/customer/booking/presentation/cubit/service_selection_cubit.dart';
import '../../features/customer/booking/presentation/cubit/slot_picker_cubit.dart';
import '../../features/customer/booking/presentation/pages/booking_confirmation_page.dart';
import '../../features/customer/booking/presentation/pages/booking_form_page.dart';
import '../../features/customer/booking/presentation/pages/organization_landing_page.dart';
import '../../features/customer/booking/presentation/pages/service_details_page.dart';
import '../../features/customer/booking/presentation/pages/service_selection_page.dart';
import '../../features/customer/booking/presentation/pages/slot_picker_page.dart';
import '../../features/customer/entry/presentation/pages/customer_home_page.dart';
import '../../features/customer/entry/presentation/cubit/customer_queue_status_cubit.dart';
import '../../features/customer/entry/presentation/pages/customer_queue_status_page.dart';
import '../../features/authentication/domain/entities/user_role.dart';
import '../../features/authentication/presentation/cubit/auth_cubit.dart';
import '../../features/authentication/presentation/cubit/auth_state.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/sign_up_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/shared_domain/entities/service_entity.dart';
import '../config/flavor_config.dart';
import '../services/onboarding_service.dart';
import '../utils/app_logger.dart';
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
  static const String adminWorkingHours = '/a/working-hours';
  static const String adminShareAccess = '/a/share-access';
  static const String customerHome = '/c/home';
  static const String customerOrgLanding = '/c/org/:slug';
  static const String customerServices = '/c/org/:slug/services';
  static const String customerServiceDetails = '/c/org/:slug/service-details';
  static const String customerSlots = '/c/org/:slug/slots';
  static const String customerBook = '/c/org/:slug/book';
  static const String customerConfirmation = '/c/org/:slug/confirmation';
  static const String customerQueueStatus = '/c/queue-status';

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
        if (isProtected) {
          final from = Uri.encodeComponent(state.uri.toString());
          return '${Routes.login}?from=$from';
        }
        return null;
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
      GoRoute(
        path: Routes.adminWorkingHours,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<WorkingHoursCubit>(),
          child: const WorkingHoursPage(),
        ),
      ),
      GoRoute(
        path: Routes.adminShareAccess,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
                final cubit = getIt<OrganizationCubit>();
                final authState = context.read<AuthCubit>().state;
                if (authState is Authenticated &&
                    authState.user.organizationId != null) {
                  cubit.watchOrganization(authState.user.organizationId!);
                }
                return cubit;
              },
            ),
            BlocProvider(create: (context) => getIt<ShareAccessCubit>()),
          ],
          child: const ShareAccessPage(),
        ),
      ),
      // Customer routes
      GoRoute(
        path: Routes.customerHome,
        builder: (context, state) => const CustomerHomePage(),
      ),
      GoRoute(
        path: Routes.customerOrgLanding,
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return BlocProvider(
            create: (context) =>
                getIt<OrganizationLandingCubit>()..loadOrganization(slug),
            child: OrganizationLandingPage(slug: slug),
          );
        },
      ),
      GoRoute(
        path: Routes.customerServices,
        builder: (context, state) {
          final (:orgId, :orgName) =
              state.extra as ({String orgId, String orgName});
          final slug = state.pathParameters['slug']!;
          return BlocProvider(
            create: (context) =>
                getIt<ServiceSelectionCubit>()..loadServices(orgId),
            child: ServiceSelectionPage(
              orgId: orgId,
              orgName: orgName,
              slug: slug,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.customerServiceDetails,
        builder: (context, state) {
          final args = state.extra as ServiceDetailsArgs;
          return ServiceDetailsPage(args: args);
        },
      ),
      GoRoute(
        path: Routes.customerSlots,
        builder: (context, state) {
          final args = state.extra as SlotPickerArgs;
          return BlocProvider(
            create: (context) => getIt<SlotPickerCubit>()
              ..init(
                orgId: args.orgId,
                serviceId: args.serviceId,
                durationMinutes: args.durationMinutes,
              ),
            child: SlotPickerPage(args: args),
          );
        },
      ),
      GoRoute(
        path: Routes.customerBook,
        builder: (context, state) {
          final args = state.extra as BookingFormArgs;
          return BlocProvider(
            create: (context) => getIt<BookingFormCubit>()
              ..init(
                orgId: args.orgId,
                serviceId: args.service.id,
                scheduledAt: args.scheduledAt,
                customerId: args.customerId,
                prefillName: args.prefillName,
              ),
            child: BookingFormPage(args: args),
          );
        },
      ),
      GoRoute(
        path: Routes.customerConfirmation,
        builder: (context, state) {
          final args = state.extra as BookingConfirmationArgs;
          return BookingConfirmationPage(args: args);
        },
      ),
      // Customer live queue status
      GoRoute(
        path: Routes.customerQueueStatus,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<CustomerQueueStatusCubit>(),
          child: const CustomerQueueStatusPage(),
        ),
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
