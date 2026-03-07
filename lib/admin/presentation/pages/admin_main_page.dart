import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app/di/injection.dart';
import '../../../core/app/theme/app_colors.dart';
import '../../dashboard/presentation/pages/admin_dashboard_tab.dart';
import '../../queue_management/presentation/pages/queue_management_page.dart';
import '../../services/presentation/cubit/service_cubit.dart';
import '../../services/presentation/pages/service_list_page.dart';
import '../../tutorial/presentation/cubit/tutorial_cubit.dart';
import '../../../shared/auth/presentation/cubit/auth_cubit.dart';
import '../../../shared/auth/presentation/cubit/auth_state.dart';
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BlocProvider(
        create: (_) => getIt<TutorialCubit>(),
        child: const AdminDashboardTab(),
      ),
      BlocProvider(
        create: (context) {
          final cubit = getIt<ServiceCubit>();
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated &&
              authState.user.organizationId != null) {
            cubit.watchServices(authState.user.organizationId!);
          }
          return cubit;
        },
        child: const ServiceListPage(),
      ),
      const QueueManagementPage(),
      const SettingsPage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
