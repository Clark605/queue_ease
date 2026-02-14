import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../admin/dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../../customer/entry/presentation/pages/customer_home_page.dart';
import '../../../shared/auth/presentation/pages/login_page.dart';

/// Route paths for the application.
abstract final class Routes {
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
GoRouter createRouter() {
  return GoRouter(
    initialLocation: Routes.adminDashboard,
    redirect: (BuildContext context, GoRouterState state) {
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
