import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../admin/dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../../customer/entry/presentation/pages/customer_home_page.dart';
import '../../../shared/auth/presentation/pages/login_page.dart';
import '../../../shared/onboarding/presentation/pages/onboarding_page.dart';
import '../di/injection.dart';
import '../../services/onboarding_service.dart';

/// Route paths for the application.
abstract final class Routes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String adminDashboard = '/a/dashboard';
  static const String customerHome = '/c/home';
}

/// Application router with RBAC-aware route structure.
///
/// Route convention:
/// - `/a/...` routes are admin-only
/// - `/c/...` routes are customer-only
/// - `/login` is the unauthenticated entry point
/// - `/onboarding` is the first-launch onboarding flow
GoRouter createRouter() {
  return GoRouter(
    initialLocation: Routes.onboarding,
    redirect: (BuildContext context, GoRouterState state) async {
      final onboardingService = getIt<OnboardingService>();
      final hasCompletedOnboarding = await onboardingService
          .hasCompletedOnboarding();

      final isOnboarding = state.matchedLocation == Routes.onboarding;
      final isRoot = state.matchedLocation == '/';

      // Handle root path: redirect based on onboarding status
      if (isRoot) {
        return hasCompletedOnboarding ? Routes.login : Routes.onboarding;
      }

      // First launch: force onboarding.
      if (!hasCompletedOnboarding && !isOnboarding) {
        return Routes.onboarding;
      }

      // Already completed onboarding but navigating to it: go to login.
      if (hasCompletedOnboarding && isOnboarding) {
        return Routes.login;
      }

      // TODO: Implement auth-aware redirect logic:
      // 1. Check if user is authenticated via AuthBloc
      // 2. If not authenticated and not on login, redirect to /login
      // 3. If authenticated, check role:
      //    - admin trying to access /c/* -> redirect to /a/dashboard
      //    - customer trying to access /a/* -> redirect to /c/home
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
      // Admin routes
      GoRoute(
        path: Routes.adminDashboard,
        builder: (context, state) => const AdminDashboardPage(),
      ),
      // Customer routes
      GoRoute(
        path: Routes.customerHome,
        builder: (context, state) => const CustomerHomePage(),
      ),
    ],
  );
}
