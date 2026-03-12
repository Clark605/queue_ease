import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queue_ease/features/admin/service_management/presentation/cubit/service_cubit.dart';
import 'package:queue_ease/features/admin/service_management/presentation/pages/service_list_page.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/pages/admin_dashboard_tab.dart';
import '../../../organization_management/presentation/cubit/organization_cubit.dart';
import '../../../queue_management/presentation/pages/queue_management_page.dart';
import '../../../tutorial/presentation/cubit/tutorial_cubit.dart';
import '../../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../../authentication/presentation/cubit/auth_state.dart';
import 'settings_page.dart';

/// Main admin page with bottom navigation bar.
///
/// Provides navigation between:
/// - Dashboard: Overview and quick access to features
/// - Services: Service management
/// - Queue: Live queue management
/// - Settings: App and organization settings
class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  /// Pages are created once in initState so IndexedStack preserves their
  /// state across tab switches. The cubits they depend on are provided by
  /// the MultiBlocProvider in [build].
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminDashboardTab(onNavigateToQueue: () => _onTabTapped(2)),
      const ServiceListPage(),
      const QueueManagementPage(),
      const SettingsPage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // OrganizationCubit — starts watching org stream on mount so the
        // dashboard and any admin tab can react to org changes immediately.
        BlocProvider(
          create: (ctx) {
            final cubit = getIt<OrganizationCubit>();
            final authState = ctx.read<AuthCubit>().state;
            if (authState is Authenticated &&
                authState.user.organizationId != null) {
              cubit.watchOrganization(authState.user.organizationId!);
            }
            return cubit;
          },
        ),
        // ServiceCubit — starts watching the service sub-collection so the
        // Services tab has live data as soon as the admin shell mounts.
        BlocProvider(
          create: (ctx) {
            final cubit = getIt<ServiceCubit>();
            final authState = ctx.read<AuthCubit>().state;
            if (authState is Authenticated &&
                authState.user.organizationId != null) {
              cubit.watchServices(authState.user.organizationId!);
            }
            return cubit;
          },
        ),
        // TutorialCubit — initialized by AdminDashboardTab once it mounts.
        BlocProvider(create: (_) => getIt<TutorialCubit>()),
      ],
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.0),
          elevation: 8,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(
                Icons.medical_services,
                color: AppColors.primary,
              ),
              label: 'Services',
            ),
            NavigationDestination(
              icon: Icon(Icons.queue_outlined),
              selectedIcon: Icon(Icons.queue, color: AppColors.primary),
              label: 'Queue',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: AppColors.primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
